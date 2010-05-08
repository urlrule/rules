#!/usr/bin/perl -w
#URL rule for http://aiyk.com/novel/47/novel47_1.html
#Date Created:Sun Mar 30 03:14:28 CST 2008
use strict;
do `IncludeFile HTML`;
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
    open FI,"-|","netcat '$url'";
    while(<FI>) {
        if(!$result{work_dir}) {
            $result{work_dir}=HTML::get_title($_);
            if($result{work_dir}) {
                $result{work_dir} =~ s/^\s*([^\s]+)\s*.*$/$1/;
            }
        }
        my @match = $_ =~ /共[0-9]+个\s*页次:[0-9]+\/([0-9]+)/;
        if(@match) {
            my $page = $match[0];
            my $base=$url;
            $base =~ s/^(.*\/novel[0-9]+)[^\/]*\.html/$1/;
            for(my $i=1;$i<=$page;$i++) {
               push(@{$result{pass_data}},"$base\_$i.html");
            }
        }
    }
    close FI;
    return %result;
}
