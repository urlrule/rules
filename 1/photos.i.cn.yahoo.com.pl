#!/usr/bin/perl -w
#http://photos.i.cn.yahoo.com/hungang1168/
#Mon May 12 15:16:08 2008
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
    $r{base}=$url;
    open FI,"-|","netcat \'$url\'";
    my $l=length($url);
    while(<FI>) {
        unless($r{work_dir}) {
            if(/<span id='nn_box'>([^<>]+)<\/span>/) {
                $r{work_dir}=$1;
            }
        }
        if(/<a href="([^"]+)"><img[^><]+alt="([^"]+)"\s*\/>/) {
            next unless(substr($1,0,$l) eq $url); 
            push @{$r{pass_data}},$1;
            push @{$r{pass_name}},$2;
        }
    }
    close FI;
    return %r;
}
