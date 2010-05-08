#!/usr/bin/perl -w
#URL rule for http://images.anime.xunlei.com/book/segment/6/5808.html
#Example Url:http://images.anime.xunlei.com/book/segment/6/5808.html
#Date Created:Fri Mar 28 02:42:07 CST 2008
use strict;

sub apply_rule {
    my $url=shift;
    my %result;
    $result{base}="http://images.mh.xunlei.com/origin/";
    $result{work_dir}="";
    $result{action}="batchget -i";
    $result{data}=[];
    $result{pass_data}=[];
    $result{pass_name}=[];
    $result{pass_arg}="";
    open FI,"-|","netcat '$url'";
    my $data=join("",<FI>);
    close FI;
    @{$result{data}} = $data =~ /images_arr\[[0-9]+\]\s*=\s*\'([^\']+)\';/gi;
    return %result;
}
