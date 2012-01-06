#!/usr/bin/perl -w
#http://blog.sina.com.cn/yxin
#Fri May  9 04:30:58 2008
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
    my $count;
    my $title;
    while(<FI>) {
        unless($title) {
            if(/<title>([^<]+?)\s*_\s*新浪博客<\/title>/) {
                $title=$1;
                $title =~ s/&nbsp;/ /;
                $title =~ s/博文_//;
                $r{work_dir}=$title;
            }
            
        }
        if(/<div\s*class="allarticles"><a\s*href="([^"]+articlelist_\d+_\d+)_1\.html"\s*class="all">[^<]+<\/a>\(<span\s*id="allArticlesCount">(\d+)<\/span>/) {
            $base=$1;
            $count=$2 / 50;
            $count++ if($2 % 50);
        }
    }
    close FI;
    if($count) {
        for my $i(1..$count) {
            push @{$r{pass_data}},"$base" . "_$i.html";
        }
    }
    else {
        push @{$r{pass_data}},$url;
    }
    $r{no_subdir}=1;
    return %r;
}
1;
