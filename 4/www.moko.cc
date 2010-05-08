#!/usr/bin/perl -w
#http://www.moko.cc/company/3/1/mokosuper.html
#Thu Jun 25 16:49:32 2009
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
	my %data = ("$rule_base"=>1);
	my @links;
    open FI,"-|","netcat \'$rule_base\'";
	while(<FI>) {
		$r{work_dir}=get_text("h1",$_) unless($r{work_dir});
		foreach(get_hrefs($_)) {
			$data{$_}=1 if(/\/\d+\/[23456789]\//);
		}
	}
    close FI;
	@{$r{pass_data}}=keys %data;
	$r{no_subdir}=1;
    return %r;
}
