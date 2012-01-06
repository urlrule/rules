#!/usr/bin/perl -w
#URL rule for http://www.imagefap.com/gallery/1100023
#Date Created:Thu Apr 24 04:24:17 CST 2008
use strict;

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
    $result{no_subdir}=1;
    my @match = $url =~ m/[\?&]gid=(\d+)/;
    unless(@match) {
        @match = $url =~ m/\/gallery\/(\d+)/;
    }
    return %result unless(@match);
    my $base = "http://www.imagefap.com/gallery.php?pgid=&gid=$match[0]";
    open FI,"-|","netcat '$url'|gb2utf";
    my $page=0;
    while(<FI>) {
        unless($result{work_dir}) {
            my @match= $_ =~ m#<font face=verdana color=white size=4><b>([^<>\b\r\n\t]+)#;
            if(@match) {
#                chomp($match[0]);
                $result{work_dir}=$match[0];
            }
        }
        my @match= $_ =~ m#href="/gallery\.php\?pgid=&gid=\d+&page=(\d+)"#;
        if(@match) {
            $page = $match[0] if($match[0]>$page);
        }
    }
    close FI;
    foreach my $i(0 .. $page) {
        push @{$result{pass_data}}, $base . "&page=$i";
    }
    return %result;
}
1;
