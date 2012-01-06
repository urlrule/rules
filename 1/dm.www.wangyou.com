#!/usr/bin/perl -w
#URL rule for http://dm.www.wangyou.com/html/class33/comic1061.html
#Example Url:http://dm.www.wangyou.com/html/class33/comic1061.html
#Date Created:Mon Mar 24 16:49:37 CST 2008
use strict;

sub apply_rule($) {
    my $url=shift;
    my %result;
    $result{base}=$url;
    $result{work_dir}="";
    $result{action}="";
    $result{data}=[];
    $result{pass_data}=[];
    open FI,"-|","netcat '$url'|gb2utf";
    while(<FI>) {
        unless($result{work_dir}) {
            my @match= $_ =~ /\<title\>\s*(.*)\s*在线漫画.*\<\/title\>/;
            if(@match) {
                $result{work_dir}=$match[0];
                $result{pass_arg}=$result{work_dir};
            }
        }
        my @match= $_ =~ m{\s+ow\s*\(\s*\'([^\']+)\?s=1\'\s*,}g;
        foreach(@match) {
            push(@{$result{pass_data}},$_);
        }
    }
    close FI;
    return %result;
}



1;
