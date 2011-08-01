#!/usr/bin/perl -w
#http://www.snaapa.com/*
#Sun Nov 14 02:38:21 2010
use strict;

use MyPlace::Curl;
#use MyPlace::HTML;

sub _process {
    my ($url,$rule,$html) = @_;
    my $title = undef;
    my @data;
    my @pass_data;
    my @html = split(/\n/,$html);
    my ($pre,$pages,$suf) = ("",1,"");
    foreach(@html) {
        s/fotop\.net/snaapa\.com/g;
        if(m/\s+href="([^"]+)"[^>]*?>\s*<img\s+/) {
            push @pass_data,$1;
        }
        if(m/src\s*=\s*"([^"]+)\.thumb(\.[^"\/]+)/) {
            my $fullurl = $1 . $2;
            if($fullurl =~ m/snaapa\.com\/(.+)$/) {
                my $baseurl = $1;
                $baseurl =~ s/\//_/g;
                push @data,$fullurl . "\t" . $baseurl;
            }
            else {
                push @data,$fullurl;
            }
        }
        if((!$title) and m/<title>\s*([^<>]+?)\s+--\s+snaapa\.com|\s*(.+?)\s+--\s+snaapa\.com[^<]+<\/title/) {
            $title =$1 if($1);
        }
        if(m/href\s*=\s*["\']?([^<>\'"]*page=)(\d+)([^<>\'"]*)/) {
            if($2 > $pages) {
                $pre = $1 if($1);
                $suf = $3 if($3);
                $pages = $2;
            }
        }
    }
    if($url !~ m/[&\?]page=\d+/) {
        if($pages>1) {
            for(my $idx=1;$idx<=$pages;$idx++) {
                push @pass_data,$pre . $idx . $suf;
            }
            @data = ();
        }
        else {
            @data = () if(@pass_data);
        }
        if($url =~ m/(.+?snaapa\.com\/)\/+(.+)$/) {
            $url = "$1$2";
            $title = $2;
            $title =~ s/\//_/g;
        }
        elsif($url =~ m/\/([^\/]+)$/) {
            $title = $title ? $1 . '_' . $title : $1;
        }
    }
    else {
        @data = () if(@pass_data);
        $title = undef;
    }
    return (
        count=>scalar(@data),
        data=>[@data],
        pass_count=>scalar(@pass_data),
        pass_data=>[@pass_data],
        base=>$url,
        no_subdir=>1,
        work_dir=>$title,
        same_level=>1,
    );
}

sub apply_rule {
    my $url = shift(@_);
    my $rule = shift(@_);
    my $http = MyPlace::Curl->new();
    my (undef,$html) = $http->get($url,'charset:BIG5-HKSCS');
    return &_process($url,$rule,$html,@_);
}


1;

__END__

#================================================================
# apply_rule will be called with ($RuleBase,%Rule),the result returned have these meaning:
# $result{base}          : Base url to build the full url
# $result{work_dir}      : Working directory (will be created if not exists)
# $result{data}          : Data array extracted from url,will be passed to $result{action}(see followed)
# $result{action}        : Command which the $result{data} will be piped to,can be overrided
# $result{pipeto}        : Same as action,Command which the $result{data} will be piped to,can be overrided
# $result{hook}          : Hook action,function process_data will be called
# $result{no_subdir}     : Do not create sub directories
# $result{pass_data}     : Data array which will be passed to next level of urlrule
# $result{pass_name}     : Names of each $result{pass_data}
# $result{pass_arg}      : Additional arguments to be passed to next level of urlrule
# urlrule_quick_parse($url,$rule,$data_exp,$data_map,$pass_exp,$pass_map,$charset)
# urlrule_parse_data($url,$rule,$data_exp,$data_map,$charset)
# urlrule_parse_pass_data($url,$rule,$pass_exp,$pass_map,$charset)
#================================================================

#       vim:filetype=perl
