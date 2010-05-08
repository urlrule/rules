#!/usr/bin/perl -w
#http://glam0ur.com/cat/Own_babes/
#Sun Feb 22 04:58:29 2009
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
use MyPlace::HTML;
sub apply_rule {
    my $rule_base= shift(@_);
    my %rule = %{shift(@_)};
    my %r;
    $r{base}=$rule_base;
    my $count = 1;
    my $prefix = 'http://glam0ur.com/cat/Own_babes/page_';
    my $suffix = '.html';
    open FI,"-|","netcat \'$rule_base\'";
    while(<FI>) {
        my @hrefs = get_hrefs($_);
        foreach(@hrefs) {
            if(/^(.*_)(\d+)\.html$/) {
                $prefix=$1 unless($prefix);
                $count=$2 if($2 > $count);
            }
        }
    }
    close FI;
    push @{$r{pass_data}},map($prefix . $_ . $suffix,(1 .. $count));
    $r{no_subdir}=1;
    return %r;
}
