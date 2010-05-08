#!/usr/bin/perl -w
#http://glam0ur.com/12791/Suzie_Carina.html
#Sun Feb 22 04:26:58 2009
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
    my $name = $rule_base;
    $name =~ s/^.*\/([^\/]+)\.html$/$1/;
    return %r unless($name);
    push @{$r{pass_data}},$rule_base;
    $r{work_dir}=$name;
    $r{no_subdir}=1;
    $name=lc($name);
    my $modelurl='http://glam0ur.com/?ctr=more_gals&model=' . $name;
    open FI,"-|","netcat \'$modelurl\'";
    while(<FI>) {
        my @hrefs = get_hrefs($_);
        push @{$r{pass_data}},grep(/\/$name\//,@hrefs) if(@hrefs);
    }
    close FI;
    return %r;
}
