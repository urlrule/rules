#!/usr/bin/perl -w
#URL rule for http://anime.xunlei.com/Book/category/579
#Example Url:http://anime.xunlei.com/Book/category/579
#Date Created:Fri Mar 28 02:33:47 CST 2008
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
    open FI,"-|","netcat '$url'";
    my @data=<FI>;
    close FI;
    $result{work_dir} = HTML::get_title(@data);
    $result{work_dir} =~ s/ - 漫画在线// if($result{work_dir});
    $result{pass_arg} = $result{work_dir};
    my @match=HTML::get_props("a","href",@data);
    foreach(@match) {
        push(@{$result{pass_data}},$_) if(/\/book\//);
    }
    @{$result{pass_data}}=reverse(@{$result{pass_data}});
    return %result;
}
