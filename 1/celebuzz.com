#!/usr/bin/perl -w
#http://www.celebuzz.com/celebrities/kim-kardashian-photos/thumbnail/
#Sat May 22 05:31:57 2010
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
    my ($url,$rule,$html) = @_;
    my @data;
    my @pass_data;

    #my @html = split(/\n/,$html);
    my $photos=0;
    my $per = 12;
    if($html =~ /"sub-header">([\d,]+)\s*Photos</) {
        $photos = $1;
        $photos =~ s/,//;
    }
    push @pass_data,$url;
    if($photos) {
        my $page = ($photos/$per)+1;
        for(2 .. $page) {
            push @pass_data,"$url?p=$_";
        }
    }
    return (data=>[@data],pass_data=>[@pass_data],base=>$url,no_subdir=>1,work_dir=>undef);
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
