#!/usr/bin/perl -w
#URL rule for http://www.waau.com/comiclist/1894/11132/1.htm
#Example Url:http://www.waau.com/comiclist/1894/11132/1.htm
#Date Created:Thu Mar 27 23:30:40 CST 2008
use strict;
do `plinclude HTML`;

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
    my $count;
    my $base = $url;
    $base =~ s/\/[^\/]+$//;
    open FI,"-|","netcat '$url'";
    while(<FI>) {
        my @match= HTML::get_props("option","value",$_);
        $count=$match[@match-1] if(@match);
    }
    close FI;
    return %result unless($count);
    for(my $i=1;$i<=$count;$i++) {
        open FI,"-|","netcat '$base/$i.htm'";
        my @data=<FI>;
        close FI;
        my $src = HTML::get_prop("img","src",@data);
        push(@{$result{data}},$src) if($src);
    }
    return %result;
}
1;
