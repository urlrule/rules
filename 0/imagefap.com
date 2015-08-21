#!/usr/bin/perl -w
#URL rule for http://www.imagefap.com/gallery.php?pgid=&gid=1054923&page=0
#Example Url:http://www.imagefap.com/gallery.php?pgid=&gid=1054923&page=0
#Date Created:Thu Apr 24 04:19:52 CST 2008
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
    my @src=get_props("img","src",<FI>);
    close FI;
    foreach(@src) {
        if(/\/thumb\//) {
            s/cache\./images./;
            s#/thumb/#/full/#;
            push @{$result{data}},$_;
        }
    }
    return %result;
}
1;
