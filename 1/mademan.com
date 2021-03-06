#!/usr/bin/perl -w
#http://www.mademan.com/chickipedia/lucy-pinder/photosgallery/
#Sat May 22 00:55:14 2010
use strict;

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
#================================================================


use MyPlace::LWP;
#use MyPlace::HTML;

sub _process {
    my ($url,$r,$rule,$data) = @_;
    $url = $url . '/' unless($url =~ /\/$/);
    #my @data = split(/\n/,$data);
    my $page = 0;
    my @match = $data =~ m/href\s*=\s*"[^"]+\/page(\d+)\.html?"/gi;
    foreach(@match) {
        $page=$_ if($_>$page);
    }
    push @{$r->{data}},$url;
    foreach(2 .. $page) {
        push @{$r->{pass_data}},$url . "page$_.html";
    }
    $r->{base}=$url;
    $r->{no_subdir}=1;
    return $r;
}

sub apply_rule {
    my $url = shift(@_);
    my %rule = %{shift(@_)};
    my %r;
    my $http = MyPlace::LWP->new();
    my (undef,$html) = $http->get($url);
    &_process($url,\%r,\%rule,$html);
    return %r;
}



#       vim:filetype=perl
1;
