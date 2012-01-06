#!/usr/bin/perl -w
#http://photos.i.cn.yahoo.com/yjj0535/967e/
#Mon May 12 15:26:12 2008
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
    my $urlfix;
    my @suburls;
    while(<FI>) {
        unless($urlfix) {
            if(/<a href="\/slideshow([^"]+)">/) {
                $urlfix=$1;
            }
        }
       if($urlfix && /<table class="pic_wrapper"><tr><td><a href="[^"]*\/([^\/"]+)\/"/) {
            push @suburls,"http://photos.i.cn.yahoo.com/down$urlfix&pid=$1";
       }
    }
    close FI;
    foreach(@suburls) {
        open FI,"-|","netcat \'$_\'";
        while(<FI>) {
    	    if(/<img src="([^"]+\/__hr_\/[^"]+)"/) {
                push @{$r{data}},$1;
                app_message("Get $1\n");
                last;
            }
        }
        close FI;
    }
    return %r;
}
1;
