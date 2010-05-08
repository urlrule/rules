#!/usr/bin/perl -w
#http://adulttextfiles.com/t/
#Thu Aug 28 02:04:53 2008
use strict;
use MyPlace::Filename qw/get_uniqname/;

#================================================================
# apply_rule will be called,the result returned have these meaning:
# $result{base}          : Base url to build the full url
# $result{work_dir}      : Working directory (will be created if not exists)
# $result{data}          : Data array extracted from url,will be passed to $result{action}(see followed)
# $result{action}        : Command which the $result{data} will be piped to,can be overrided
# $result{hook}          : Hook action,function process_data will be called
# $result{no_subdir}     : Do not create sub directories
# $result{pass_data}     : Data array which will be passed to next level of urlrule
# $result{pass_name}     : Names of each $result{pass_data}
# $result{pass_arg}      : Additional arguments to be passed to next level of urlrule
#================================================================
sub apply_rule {
    my $url=shift;
    my %r;
    $r{base}=$url;
    open FI,"-|","netcat \'$url\'";
    while(<FI>) {
        if(/\<A\s*HREF\s*=\s*\"([^\"]+)\".*?\<TD\>.*?\<TD\>\s*(.*?)\s*$/) {
            my $link = build_url($r{base},$1);
            push @{$r{data}},"download -u '$link' -s '$2.txt' -a"; 
        }
    }
    close FI;
    my $taskname = $url;
    $taskname =~ s/^.*://g;
    $taskname =~ s/^\/*//g;
    $taskname =~ s/\/*$//g;
    $taskname =~ s/\//_/g;
    $r{action}="r-tasks -n '$taskname' -t line -l tasks.log";
    $r{no_subdir}=1;
    return %r;
}

