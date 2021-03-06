#!/usr/bin/perl -w
#http://blog.sina.com.cn/s/articlelist_1198255605_0_2.html
#Fri May  9 04:25:52 2008
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
#================================================================

sub apply_rule {
    my $url=shift;
    my %r;
    $r{base}=$url;
    open FI,"-|","netcat \'$url\'";
    my @links = get_props("a","href",<FI>);
    close FI;
    for(@links) {
        push(@{$r{pass_data}},$_) if(/\/s\/blog_/);
    }
    $r{no_subdir}=1;
    return %r;
}
1;
