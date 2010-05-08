#!/usr/bin/perl -w
#http://pascal:notworki@members.mr13inch.com/restricted/xxxgalleries/preciouspussy.phtml
#Sat Sep 20 06:12:28 2008
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
    my @links = get_props("a","href",<FI>);
    close FI;
    my ($base,$count) = ("",0);
    foreach(@links) {
        if(/^(.*)\/set(\d+)\/[^\/]+\.htm$/) {
            $base = $1 unless($base);
            $count = $2 if($count < $2);
        }
    }
    foreach(1 .. $count) {
        push @{$r{pass_data}},$base . "/set" . $_ . "/ulthm.htm";
        push @{$r{pass_name}}, "set" . $_;
    }
    return %r;
}
