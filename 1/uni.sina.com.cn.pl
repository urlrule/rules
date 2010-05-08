#!/usr/bin/perl -w
#http://uni.sina.com.cn/c.php?t=album&k=%D1%EE%D0%C0&ft=1
#Fri May  9 16:27:49 2008
use strict;

#================================================================
# apply_rule will be called,the result returned have these meaning:
# $result{base}          : Base url to build the full url
# $result{work_dir}      : Working directory (will be created if not exists)
# $result{data}          : Data array extracted from url,will be passed to $result{action}(see followed)
# $result{action}        : Command which the $result{data} will be piped to,can be overrided
# $result{no_subdir}     : Do not create sub directories
# $result{pass_data}     : Data array which will be passed to next level of urlrule
# $result{pass_name}     : Names of each $result{pass_data}
# $result{pass_arg}      : Additional arguments to be passed to next level of urlrule
#================================================================

sub apply_rule {
    my $url=shift;
    my %r;
    $url =~ s/&page=\d+//;
    $r{base}=$url;
    my $pages;
    open FI,"-|","netcat \'$url\'";
    while(<FI>) {
        if(/writeCleftPage\(\s*(\d+)\s*,\s*(\d+)\s*,/) {
            $pages = $1 / $2 ;
            $pages ++ if($1 % $2);
            last;
        }
    }
    close FI;
    for my $i (1 .. $pages) {
        push @{$r{pass_data}},$url . "&page=" . $i;
    }
    $r{no_subdir}=1;
    return %r;
}
