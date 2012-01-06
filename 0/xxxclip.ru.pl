#!/usr/bin/perl -w
#http://xxxclip.ru/2008/05/07/aziatka_i_miniet.html
#Wed May 14 00:25:26 2008
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
    my $src = get_prop("embed","src",<FI>);
    close FI;
    if($src) {
        $r{work_dir}=$1 if($src =~ /\/([^\/]+)\/[^\/]+$/);
        push @{$r{data}},$src;
    }
    return %r;
}

1;
