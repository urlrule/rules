#!/usr/bin/perl -w
#http://a.99tc.com/article/dmtp/
#Fri Feb  6 15:18:25 2009
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
    open FI,"-|","netcat \'$rule_base\'";
    my $count=1;
    my $prefix="";
    while(<FI>) {
        $r{work_dir}=get_title($_) unless($r{work_dir});
        my @hrefs = get_hrefs($_);
        foreach(@hrefs) {
            if(/(list_\d+_)(\d+)/) {
                $prefix=$1;
                $count=$2 if($2>$count);
            }
        }
    }
    close FI;
    push @{$r{pass_data}},"index.html";
    if($count>1) {
        push @{$r{pass_data}},map {$prefix . $_  . ".html"} (2..$count); 
    }
    $r{no_subdirs}=1;
    $r{work_dir} =~ s/\s*-.*$// if($r{work_dir});
    return %r;
}
1;
