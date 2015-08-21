#!/usr/bin/perl -w
#URL rule for http://www.wallpaperme.com/Celebrities-K-L/Kirsty-Gallacher/
#Example Url:http://www.wallpaperme.com/Celebrities-K-L/Kirsty-Gallacher/
#Date Created:Wed Apr 16 17:53:08 CST 2008
use strict;
use MyPlace::HTML;

sub apply_rule {
    my $url=shift;
    my %result;
    $result{base}=$url;
    $result{work_dir}="";
    $result{action}="batchget";
    $result{data}=[];
    $result{pass_data}=[];
    $result{pass_name}=[];
    $result{pass_arg}="";
    open FI,"-|","netcat '$url'|gb2utf";
    my @imgs = get_props("img","src",<FI>);
    close FI;
    foreach(@imgs) {
        if(/\/(\d+)-(\d+)\/([^\/]+\.jpg)/i) {
            push @{$result{data}},"\/" . ($1-1) . "-$2\/$3";
        }
    }
    return %result;
}
1;
