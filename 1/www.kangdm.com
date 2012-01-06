#!/usr/bin/perl -w
#URL rule for http://www.kangdm.com/comic/3648/
#Example Url:http://www.kangdm.com/comic/3648/
#Date Created:Mon Mar 24 08:25:07 CST 2008
use strict;
use URI::Escape;

sub apply_rule($) {
    my $url=shift;
    my %result;
    $result{base}=$url;
    $result{work_dir}="";
    $result{action}="";
    $result{data}=[];
    $result{pass_data}=[];
    $result{pass_arg}="";
    open FI,"-|","netcat '$url' | gb2utf";
    while(<FI>) {
        unless($result{work_dir}) {
            my @match = $_ =~ m/\<title\>([^\<\>]*)\<\/title\>/;
            if(@match) {
                $result{work_dir}=$match[0];
                $result{work_dir} =~ s/[_\[].*$//g;
                $result{pass_arg} = $result{work_dir};
            }
        }
        my @match= $_ =~ /href=\"([^#\/\.][^\":]*)\"/g;
        push(@{$result{pass_data}},@match) if(@match);
    }
    close FI;
    return %result;
}
1;
