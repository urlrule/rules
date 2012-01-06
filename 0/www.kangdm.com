#!/usr/bin/perl -w
#URL rule for http://www.kangdm.com/comic/3648/oh%E9%80%8F%E6%98%8E%E4%BA%BA%E9%97%B4%E7%AC%AC1%E5%8D%B7
#Example Url:http://www.kangdm.com/comic/3648/oh%E9%80%8F%E6%98%8E%E4%BA%BA%E9%97%B4%E7%AC%AC1%E5%8D%B7
#Date Created:Mon Mar 24 06:47:03 CST 2008
use strict;
use URI;

sub apply_rule {
    my $url=shift;
    my $jobname=shift;
    $jobname="" unless($jobname);
    my %result;
    $url=$url . "\/index.js";
    $result{work_dir}="";
    $result{action}="batchget -b http://www.kangdm.com -n '$jobname'"; 
    $result{data}=[];
    $result{pass_data}=[];
    open FI,"-|","netcat '$url'|gb2utf";
    my $total;
    my $base;
    my $tpf=0;
    while(<FI>) {
        my @match = $_ =~ /.*total\s*=\s*([0-9]+).*volpic\s*=\s*'([^\']+)'.*tpf\s*=\s*([0-9]+)/;
        if(@match) {
            $total=$match[0];
            $result{base}=URI->new($match[1]);
            $tpf=$match[2];
            last;
        }
    }
    close FI;
    return %result unless($total);
    for(my $i=1;$i<$total;$i++) {
        my $l=length($i);
        my $name;
        if($l > $tpf) {
            $name = "$i.jpg";
        }
        else {
            $name = "0" x ($tpf - $l + 1) . "$i.jpg";
        }
        push(@{$result{data}},$name);
    }
    return %result;
}






1;
