#!/usr/bin/perl -w
#http://wpf6188.tuzhan.com/album/410d2a8586ab0c01.html
#Mon Aug 16 21:50:26 2010
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
    return (
        '#use quick parse'=>1,
        'data_exp'=>'<img src="([^"]+)_s.jpg"',
        'data_map'=>'"$1_l.jpg"',
    );
}



#       vim:filetype=perl
