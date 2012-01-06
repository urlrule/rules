#!/usr/bin/perl -w
#http://ent.sina.com.cn/s/m/f/yangx/index.html
#Fri May  9 16:58:50 2008
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
        if(/^http:\/\/(ent|blog)\.sina\.com\.cn\/.*html$/i) {
            push @{$r{pass_data}},$_;
        }
    }
    $r{no_subdir}=1;
    return %r;
}
1;
