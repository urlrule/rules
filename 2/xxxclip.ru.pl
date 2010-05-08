#!/usr/bin/perl -w
#http://xxxclip.ru/porno/
#Wed May 14 01:12:53 2008
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
    my $base;
    my $pages=0;
    while(<FI>) {
        while(m{<a href="([^"]+)/page/(\d+)/">(\d+)</a>}g) {
            next unless($2 == $3);
            if($2 > $pages) {
                $pages=$2;
                $base= $1 . "/page/";
            }
        }
    }
    close FI;
    if($base && $pages>0) {
        foreach(1 .. $pages) {
            push @{$r{pass_data}},$base . $_ . "/";
        }
    }
    $r{no_subdir}=1;
    return %r;
}
