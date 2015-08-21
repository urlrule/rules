#!/usr/bin/perl -w
#URL rule for http://www.adult168.com/html/f187.html
#Example Url:http://www.adult168.com/html/f187.html
#Date Created:Sun Mar 30 02:55:45 CST 2008
use strict;

sub apply_rule {
    my $url=shift;
    my %result;
    $result{work_dir}="";
    $result{action}="";
    $result{data}=[];
    $result{name}="";
    $result{pass_data}=[];
    $result{pass_name}=[];
    $result{pass_arg}="";
    $result{no_subdir}="true";
    open FI,"-|","netcat '$url'| htmllinks | sort -u";
    while(<FI>) {
        chomp;
        if(/\/html\/[0-9]+\//i or /viewarticle/i) {
            push(@{$result{data}},$_);
        }
    }
    close FI;
    return %result;
}
1;
