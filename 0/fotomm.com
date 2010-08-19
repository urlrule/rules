#!/usr/bin/perl -w
#http://fotomm.com
#Tue Aug 17 00:53:02 2010
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
# urlrule_quick_parse($url,$rule,$data_exp,$data_map,$pass_exp,$pass_map,$charset)
# urlrule_parse_data($url,$rule,$data_exp,$data_map,$charset)
# urlrule_parse_pass_data($url,$rule,$pass_exp,$pass_map,$charset)
#================================================================

#
sub apply_rule {
# return urlrule_quick_parse($_[0],$_[1],$data_exp,$data_map,$pass_exp,$pass_map,$charset);
# return urlrule_parse_data($_[0],$_[1],$data_exp,$data_map,$charset);
# return urlrule_parse_pass_data($_[0],$_[1],$pass_exp,$pass_map,$charset);
 return (
       '#use quick parse'=>1,
       'data_exp'=>'title="[^"]+" alt="[^"]+" src="([^"]+)/thumbs/thumbs_([^"]+)"',
       'data_map'=>'"$1/$2"',
#       'pass_exp'=>undef,
#       'pass_data'=>undef,
#       'charset'=>undef
 );
}




#       vim:filetype=perl
