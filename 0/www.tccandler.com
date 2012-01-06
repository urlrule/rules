#!/usr/bin/perl -w
#URL rule for http://www.tccandler.com/talent_file_kirsty_gallagher.htm
#Example Url:http://www.tccandler.com/talent_file_kirsty_gallagher.htm
#Date Created:Tue Apr 15 19:22:45 CST 2008
use strict;
use MyPlace::HTML;

sub apply_rule {
    my $url=shift;
    my %result;
    $result{base}=$url;
    $result{work_dir}="";
    $result{action}="";
    $result{data}=[];
    $result{pass_data}=[];
    $result{pass_name}=[];
    $result{pass_arg}="";
    open FI,"-|","netcat '$url'|gb2utf";
    my @links=get_hrefs(<FI>);
    foreach(@links) {
        push(@{$result{data}},$_) if(/\.jpg$/i);
    }
    close FI;
    return %result;
}
1;
