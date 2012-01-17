#!/usr/bin/perl -w
#http://www.moko.cc/busisi/
#http://www.moko.cc/post/zhangyinghan/
#Thu Jun 25 15:59:40 2009
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

sub apply_rule {
    my $rule_base= shift(@_);
    my %rule = %{shift(@_)};
    my %r;
	my $id;
	if($rule_base =~ /moko\.cc\/post\/([^\/]+)\/?$/) {
		$id = $1;
	}
	elsif($rule_base =~ /moko\.cc\/([^\/]+)\/?$/) {
		$id = $1;
	}
	else {
		return ();
	}
	$rule_base = "http://www.moko.cc/post/$id/1/postsortid.html";
    $r{work_dir}=$id;
    $r{base}=$rule_base;
	$r{pass_data} = [$rule_base];
	$r{no_subdir} = 1;
    return %r;
}

#	vi: set filetype=perl : 
1;
#   vim:filetype=perl
