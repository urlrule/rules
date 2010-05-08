#!/usr/bin/perl -w
#URL rule for http://dm.www.wangyou.com/html/class33/comic1061.html
#Example Url:http://dm.www.wangyou.com/html/class33/comic1061.html
#Date Created:Mon Mar 24 18:20:30 CST 2008
use strict;

sub apply_rule($) {
    my $url=shift;
    my %result;
    $url =~ s/view(.+)\.html$/js$1.js/;
    $result{work_dir}="";
    $result{action}="";
    $result{data}=[];
    $result{pass_data}=[];
    open FI,"-|","netcat '$url'|gb2utf";
    while(<FI>) {
        unless($result{base}) {
            my @match = $_ =~ /^\s*var\s*pic_path2\s*=\s*\'(.+)\';\s*$/i;
            $result{base}=$match[0] if(@match);
        }
        my @match = $_ =~ /^\s*datas\[[0-9]+\]\s*=\s*\'(.+)\';\s*$/i;
        if(@match) {
            push(@{$result{data}},wy_decode($match[0]));
        }
    }
    close FI;
    return %result;
}

sub wy_decode($) {
    my $text=shift;
    $text =~ s/\\\\/\\/g;
    my $dst="";
    my $i=0;
    my $f=0;
    my $flg=0;
    foreach($text =~ /(.)/g) {
        my $c = ord($_);
        if($c != 35) {
            if($f != 0  and $f == $i-1) {
                $dst .= $_;
            }
            else {
                $dst .= chr($c - $flg);
            }
            $flg++;
        }
        else {
            $f=$i;
        }
        $i++;
    }
    return $dst;
}

