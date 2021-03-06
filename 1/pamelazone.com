#!/usr/bin/perl -w
#http://kimkardashianweb.com/gallery/index.php?cat=4
#Sat May 22 04:14:36 2010
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

sub _process_cat {
    my($url,$html,$cats,$albums) = @_;
    my @html = split(/\n/,$html);
    foreach(@html) {
        if(/(index\.php\?cat=\d+)/) {
            if(!$cats->{$1}) {
                $cats->{$1}=1;
                my $http = MyPlace::LWP->new();
                app_message "Process $url/$1\n";
                my (undef,$data) = $http->get("$url/$1");
                &_process_cat($url,$data,$cats,$albums);
            }
        }
        if(/(thumbnails\.php\?album=\d+)/) {
#            print STDERR "Get $1\n";
            $albums->{$1}=1;
        }
    }
}


sub _process {
    my ($url,$rule,$html) = @_;
    my @data;
    my @pass_data;

    my %cats;
    my %albums;

    my $id = $url;
    $id =~ s/^.*\///;
    my $base = $url;
    $base =~ s/\/[^\/]+$//;
    $cats{$id}=1;
    &_process_cat($base,$html,\%cats,\%albums);
    return (data=>[@data],pass_data=>[keys %albums],base=>$url,no_subdir=>1,work_dir=>undef);
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
