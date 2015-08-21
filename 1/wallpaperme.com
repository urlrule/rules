#!/usr/bin/perl -w
#URL rule for http://www.wallpaperme.com/Celebrities-K-L/Kirsty-Gallacher/
#Example Url:http://www.wallpaperme.com/Celebrities-K-L/Kirsty-Gallacher/
#Date Created:Wed Apr 16 17:43:42 CST 2008
use strict;
use MyPlace::HTML;
sub apply_rule {
    my $url=shift;
    my %result;
    $result{base}=$url;
    $result{base} =~ s/\/[^\/]*$/\//;
    $result{work_dir}=$result{base};
    $result{work_dir} =~ s/^.*\/([^\/]+)\/$/$1/;
    $result{work_dir} =~ s/-/ /;
    $result{no_subdir}=1;
    $result{action}="";
    $result{data}=[];
    $result{pass_data}=[];
    $result{pass_name}=[];
    $result{pass_arg}="";
    open FI,"-|","netcat '$url'|gb2utf";
    my @links = get_hrefs(<FI>);
    close FI;
    my $pages=1;
    foreach(@links) {
        if(/\?g2_page=(\d+)$/) {
            $pages=$1 if($1>$pages);
        }
    }
    push @{$result{pass_data}},$result{base};
    for(my $i=2;$i<=$pages;$i++) {
        push @{$result{pass_data}},$result{base} . "?g2_page=$i";
    }
    return %result;
}
1;
