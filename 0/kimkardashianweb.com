#!/usr/bin/perl -w
#http://kimkardashianweb.com/gallery/thumbnails.php?album=716
#Sat May 22 03:55:37 2010
use strict;

#================================================================
# apply_rule will be called with ($RuleBase,%Rule),the result returned have these meaning:
# $result{base}          : Base url to build the full url
# $result{work_dir}      : Working directory (will be created if not exists)
# $result{data}          : Data array extracted from url,will be passed to $result{action}(see followed)
# $result{action}        : Command which the $result{data} will be piped to,can be overrided
# $result{pipeto}        : Same as action,Command which the $result{data} will be piped to,can be overrided
# $result{hook}          : Hook action,function process_data will be called
# $result{no_subdir}     : Do not create sub directories
# $result{pass_data}     : Data array which will be passed to next level of urlrule
# $result{pass_name}     : Names of each $result{pass_data}
# $result{pass_arg}      : Additional arguments to be passed to next level of urlrule
#================================================================


use MyPlace::LWP;
#use MyPlace::HTML;

sub _process {
    my ($url,$rule,$html,$nopaging) = @_;
    my @data;
    my @pass_data;
   
    my $title;
    my $page=0;
    my @html = split(/\n/,$html);
    foreach(@html) {
        if((!$nopaging)) {
            if($_ =~ /"[^"]+page=(\d+)"/) {
                $page = $1 if($1>$page);
            }
            if((!$title) and $_ =~ /<title>[^-]+-\s+(.+)</) {
                $title = $1;
                $title =~ s/[\s\.]*$//;
            }
        }
        if(/src\s*=\s*"([^"]+thumb_[^"]+)"/) {
            my $src = $1;
            $src =~ s/thumb_//;
            push @data,$src;
        }
    }
    if(!$nopaging) {
        foreach(2 .. $page) {
            my $nextpage = "$url&page=$_";
            my $http = MyPlace::LWP->new();
            my (undef,$nexthtml) = $http->get($nextpage);
            my %r = &_process($nextpage,$rule,$nexthtml,1);
            push @data,@{$r{data}} if($r{data});
        }
    }

    return (data=>[@data],pass_data=>[@pass_data],base=>$url,no_subdir=>1,work_dir=>$title);
}

sub apply_rule {
    my $url = shift(@_);
    my %rule = %{shift(@_)};
    my $http = MyPlace::LWP->new();
    my (undef,$html) = $http->get($url);
    return &_process($url,\%rule,$html);
}



#       vim:filetype=perl
1;
