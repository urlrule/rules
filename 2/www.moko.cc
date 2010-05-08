#!/usr/bin/perl -w
#http://www.moko.cc/busisi/
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
use MyPlace::HTML;
sub apply_rule {
    my $rule_base= shift(@_);
	if($rule_base =~ /\/www\.moko\.cc\/([^\/]+)\/?$/) {
		$rule_base = "http://www.moko.cc/post/$1/indexpost.html";
	}
	my $id;
	if($rule_base =~ /\/post\/([^\/]+)\//) {
		$id=$1;
	}
    my %rule = %{shift(@_)};
    my %r;
    $r{base}=$rule_base;
    open FI,"-|","netcat \'$rule_base\'";
	my @text =<FI>;
	close FI;
	$r{work_dir} = get_title(@text);
	if($id) {
		$r{work_dir} = $id . ($r{work_dir} ? "_" . $r{work_dir} : "");
	}
	$r{work_dir} =~ s/'s.*$// if($r{work_dir});
	foreach(get_hrefs(@text)) {
		push @{$r{pass_data}},$_ if(/postclass\.html$/);
	}
	push @{$r{pass_data}},$rule_base unless($r{pass_data});
	$r{no_subdir}=1;
    return %r;
}

#	vi: set filetype=perl : 
