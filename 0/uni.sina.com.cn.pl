#!/usr/bin/perl -w
#http://uni.sina.com.cn/c.php?t=album&k=%D1%EE%D0%C0&ft=1&page=4
#Fri May  9 16:20:32 2008
use strict;
use MyPlace::HTML;

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
# $result{pass_level}    : Specify the level of passing,instead of next level
#================================================================

sub apply_rule {
    my $url=shift;
    my %r;
    $r{base}=$url;
    open FI,"-|","netcat \'$url\'";
    my @DATA=<FI>;
    close FI;
    my @imgs = get_props("img","src",@DATA);
    for(@imgs) {
        if(m{photo\.sina\.com\.cn/small/}) {
            s{/small/}{/orignal/};
            push @{$r{data}},$_;
        }
    }
    my @links = get_props("a","href",@DATA);
    foreach(@links) {
        if(/blog\.sina\.com\.cn\/.*\.html$/) {
            push @{$r{pass_data}},$_;
        } 
    }
    $r{pass_level}=0;
    $r{no_subdir}=1;
    return %r;
}
1;
