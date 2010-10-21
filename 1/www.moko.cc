#!/usr/bin/perl -w
#Thu Jun 25 15:23:48 2009
#http://www.moko.cc/post/zhangyinghan/818/1/postclass.html
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
    open FI,"-|","netcat \"$rule_base\"";
    while(<FI>) {
		my $title = get_text("h1",$_) unless($r{work_dir});
                if($title) {
                    $title =~ s/(\s+|\s*\(\s*\d+\s*\)\s*)$//;
    		    $r{work_dir}=$title;
                }
		if(/(\/post\/[^\/]+\/\d+\/\d+\.html)/i) {
		    $data{$1}=1; 
                }
                elsif(/(\/post\/[^\/]+\/\d+\/\d+\/\d+\.html)/i) {
                    $data{$1}=1;
                }
    }
    close FI;
    $r{no_subdir}=1;
	push @{$r{pass_data}},keys %data if(%data);
    return %r;
}
