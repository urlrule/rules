#!/usr/bin/perl -w
#URL rule for http://img129.hotlinkimage.com/img.php?id=1581045680
#Example Url:http://img129.hotlinkimage.com/img.php?id=1581045680
#Date Created:Sun Apr 13 04:07:32 CST 2008
use strict;
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
    my $exp=qr/src="([^"]+\.jpg)"/i;
    while(<FI>) {
        my @match = m/$exp/;
        if(@match) {
            push(@{$result{data}},$match[0]);
            last;
        }
    }
    close FI;
    return %result;
}
1;
