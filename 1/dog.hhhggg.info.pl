#!/usr/bin/perl -w
#http://dog.hhhggg.info/ll/
#Thu Aug 21 15:34:59 2008
use strict;
use MyPlace::HTML;

#================================================================
# apply_rule will be called,the result returned have these meaning:
# $result{base}          : Base url to build the full url
# $result{work_dir}      : Working directory (will be created if not exists)
# $result{data}          : Data array extracted from url,will be passed to $result{action}(see followed)
# $result{action}        : Command which the $result{data} will be piped to,can be overrided
# $result{no_subdir}     : Do not create sub directories
# $result{pass_data}     : Data array which will be passed to next level of urlrule
# $result{pass_name}     : Names of each $result{pass_data}
# $result{pass_arg}      : Additional arguments to be passed to next level of urlrule
#================================================================

sub apply_rule {
    my $url=shift;
    my %r;
    $r{base}=$url;
    open FI,"-|","netcat \'$url\'";
    my @text = <FI>;
    close FI;
    my @links = get_hrefs(@text);
    my $count=0;
    foreach my $link (@links) {
        if($link =~ m/\?Page=(\d+)$/) {
            $count=$1 if($1 > $count);
        }
    }
    foreach my $page (1 .. $count) {
        push @{$r{pass_data}},"?Page=" . $page; 
    }
    $r{no_subdir}=1;
    return %r;
}
1;
