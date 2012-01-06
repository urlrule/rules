#!/usr/bin/perl -w
#URL rule for http://comic.kukudm.com/comiclist/308/index.htm
#Example Url:http://comic.kukudm.com/comiclist/308/index.htm
#Date Created:Tue Mar 25 15:20:17 CST 2008
use strict;

sub apply_rule($) {
    my $url=shift;
    my %result;
    $result{base}=$url;
    $result{work_dir}="";
    $result{action}="";
    $result{data}=[];
    $result{pass_data}=[];
    my $pdir=$url;
    $pdir =~ s/.*:\/\/[^\/]+(\/.+)\/[^\/]+$/$1/;
    open FI,"-|","netcat '$url'|gb2utf";
    while(<FI>) {
        unless($result{work_dir}) {
            my @match= $_ =~ /\<title\>\s*(.*)\s*漫画在线.*\<\/title\>/i;
            $result{work_dir}=$match[0] if(@match);
        }
        my @match= $_=~ /\<a\s+href\s*=\s*\'($pdir\/[^\/\']+\/[^\']+)\'/gmi;
        push(@{$result{pass_data}},@match) if(@match);
    }
    close FI;
    return %result;
}
1;
