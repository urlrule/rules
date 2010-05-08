#!/usr/bin/perl -w
#http://www.moko.cc/MOKO_POST_ORDER_MOKO/1/postList.html
#Thu Jun 25 16:30:24 2009
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
	my %data;
    open FI,"-|","netcat \'$rule_base\'";
	my @links = get_hrefs(<FI>);
	close FI;
	foreach(@links) {
		next if(/\.html$/);
		$data{$_} = 1 if(/^\/[^\/]+\/?$/);
	}
	push @{$r{pass_data}},keys %data if(%data);
	$r{no_subdir}=1;
    return %r;
}
