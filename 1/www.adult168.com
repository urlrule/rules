#!/usr/bin/perl -w
#URL rule for http://www.adult168.com/html/f187.html
#Example Url:http://www.adult168.com/html/f187.html
#Date Created:Sun Mar 30 03:14:28 CST 2008
use strict;
use MyPlace::HTML;

sub apply_rule {
    my $url=shift;
    my %result;
    $result{work_dir}="";
    $result{action}="";
    $result{data}=[];
    $result{pass_data}=[];
    $result{pass_name}=[];
    $result{pass_arg}="";
    $result{no_subdir}="true";
    open FI,"-|","netcat '$url'|gb2utf";
    while(<FI>) {
        if(!$result{work_dir}) {
            $result{work_dir}=get_title($_);
            if($result{work_dir}) {
                $result{work_dir} =~ s/^.*\s+([^\s]+)\s*$/$1/;
            }
        }
        my @match = $_ =~ /共收录主题数:\s*([0-9]+).*每页显示数:\s*([0-9]+)\s*/;
        if(@match) {
            my $total=$match[0];
            my $per=$match[1];
            my $page = int($total/$per);
            $page++ if($total%$per);
            my $base=$url;
            $base =~ s/^(.*\/[a-z][0-9]+)[^\/]*\.html/$1/;
            push(@{$result{pass_data}},"$base.html");
            for(my $i=1;$i<=$page;$i++) {
               push(@{$result{pass_data}},"$base\_$i.html");
            }
        }
    }
    close FI;
    return %result;
}
