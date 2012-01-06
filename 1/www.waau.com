#!/usr/bin/perl -w
#URL rule for http://www.waau.com/comiclist/1894/index.htm
#Example Url:http://www.waau.com/comiclist/1894/index.htm
#Date Created:Thu Mar 27 23:07:08 CST 2008
use strict;
do `plinclude HTML`;

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
    while(<FI>) {
        unless($result{work_dir}) {
            $result{work_dir}=HTML::get_title($_);
            $result{work_dir} =~ s/在线漫画 - (.*)\s+$/$1/;
            $result{pass_arg}=$result{work_dir};
        }
#        my @match = HTML::get_href($_);
        foreach(HTML::get_hrefs($_)) {
            push(@{$result{pass_data}},$_) if(/\/comiclist\/.*\/1\.htm/);
        }
    }
    close FI;
    @{$result{pass_data}}= reverse(@{$result{pass_data}}) if($result{pass_data});
    return %result;
}
1;
