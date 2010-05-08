#!/usr/bin/perl -w
#URL rule for http://aiyk.com/novel/47/novel47_1.html
#Example Url:http://aiyk.com/novel/47/novel47_1.html
#Date Created:Sun Mar 30 09:56:48 CST 2008
use strict;
do `IncludeFile HTML`;

sub apply_rule {
    my $url=shift;
    my %result;
    $result{base}=$url;
    $result{no_subdir}="true";
    $result{work_dir}="";
    $result{action}="";
    $result{data}=[];
    $result{pass_data}=[];
    $result{pass_name}=[];
    $result{pass_arg}="";
    open FI,"-|","netcat '$url'";
    my @data=<FI>;
    close FI;
    foreach(HTML::get_hrefs(@data)) {
        push(@{$result{pass_data}},$_) if(/\/[0-9_]+\.html$/);
    }
    return %result;
}
