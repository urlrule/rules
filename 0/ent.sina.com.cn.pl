#!/usr/bin/perl -w
#http://ent.sina.com.cn/s/m/2008-02-20/15461918219.shtml
#Fri May  9 15:56:40 2008
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
    if($url =~ m{/download/photo/}) {
        while(<FI>) {
            if(m{data_p\[dt_i\]\[cul_name\]=\'([^']+\.[Jj][Pp][Gg])\';}){
                my $img=$1;
                $img =~ s/_small//;
                push @{$r{data}},$img;
            }
        }
    }
    else {
    my @imgs = get_props("img","src",<FI>);
    for(@imgs) {
        if(/(sinaimg\..*\.jpg|image\d+\.sina\.com\.cn\/ent.*\.jpg)$/i) {;
            s/_small//;
            push @{$r{data}},$_;
        }
    }
    }
    close FI;
    return %r;
}
1;
