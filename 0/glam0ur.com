#!/usr/bin/perl -w
#http://glam0ur.com/gals/divini_rae/15/index.php
#Sun Feb 22 04:07:10 2009
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
    $r{pipeto}='batchget -a';
    my @urls;
    open FI,"-|","httpcat \'$rule_base\'";
    while(<FI>) {
        my @hrefs = get_props("img","src",$_);
        foreach(@hrefs) {
            if(/thumbs\//) {
                s/thumbs\///;
                push @urls,$_;
            }
            elsif(/\/(:?tn_|_)/) {
                s/\/(:?tn_|_)/\//;
                push @urls,$_;
            }
        }
        @hrefs = get_props("a","href",$_);
        push @urls,map({s/\.htm[l]$/\.jpg/;$_} grep(/\.(:?htm[l]|jpg)$/,@hrefs)) if(@hrefs);
    }
    close FI;
    my %urls;map {$urls{$_}=1} @urls;
    $r{data} = [keys %urls];
    return %r;
}
