#!/usr/bin/perl -w
#URL rule for http://aiyk.com/novel/47/16845_1.html
#Date Created:Sun Mar 30 03:14:28 CST 2008
use strict;
do `IncludeFile HTML`;
do `IncludeFile HTML/Convertor`;
sub apply_rule {
    my $url=shift;
    my %result;
    $result{action}="";
    $result{data}=[];
    $result{pass_data}=[];
    $result{pass_name}=[];
    $result{pass_arg}="";
    $result{no_subdir}="true";
    open FI,"-|","netcat '$url'";
    my $title;
    my @urls;
    while(<FI>) {
        if(!$title) {
            $title=HTML::get_title($_);
        }
        my @match = $_ =~ /共([0-9]+)页/;
        if(@match) {
            my $page = $match[0];
            my $base=$url;
            $base =~ s/_[0-9]+\.html//;
            for(my $i=1;$i<=$page;$i++) {
               push(@urls,"$base\_$i.html");
            }
            last;
        }
    }
    close FI;
    return %result unless($title);
    return %result unless(@urls);
    $title =~ s/-[^-]+-[^-]+$//;
    $title =~ s/&nbsp;//g;
    push @{$result{data}},"Saved to $title.txt";
    open FO,">","$title.txt";
    foreach(@urls){
        open FI,"-|","netcat '$_'";
        my @data;
        while(<FI>) {
            if(/^\s*共[0-9]+页/) {
                push(@data,"</table>");
                last;
            }
            s/&nbsp;|&quot;//g;
            push(@data,$_);
        }
        close FI;
        my @rootid=qw/content/;
        @data=HTML::Convertor::to_text(\@data,\@rootid);
        print FO @data,"\n";
    }
    close FO;
    return %result;
}
1;
