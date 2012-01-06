#!/usr/bin/perl -w
#URL rule for http://comic.kukudm.com/comiclist/308/4307/1.htm
#Example Url:http://comic.kukudm.com/comiclist/308/4307/1.htm
#Date Created:Tue Mar 25 15:48:45 CST 2008
use strict;

sub apply_rule($) {
    my $url=shift;
    my %result;
    $result{base}="http://c3.kukudm.com/";
    $result{action}="batchget";
    $result{data}=[];
    $result{pass_data}=[];
    $result{pass_name}=[];
    $result{no_subdir}=[];
    my $url_exp=qr/\<img.+src\s*=\s*\'\"\+server\+\"([^\'\"\>]+)\'\>\"/i;
    my $url_base=$url;
    $url_base =~ s/\/[^\/]*$//;
    my $count;
    open FI,"-|","netcat '$url'|gb2utf";
    while(<FI>) {
        unless($count) {
            my @match = $_ =~ /共([0-9]+)页/;
            if(@match) {
                $count=$match[0];
                last;
            }
        }
    }
    close FI;
    return %result unless($count);
    for(my $i=1;$i<=$count;$i++) {
        my $suburl="$url_base/$i.htm";
        open FI,"-|","netcat '$suburl' | gb2utf";
        while(<FI>) {
            my @match = $_ =~ $url_exp;
            if(@match) {
                push(@{$result{data}},$match[0]);
                last;
            }
        }
        close FI;
    }
    return %result;
}
1;
