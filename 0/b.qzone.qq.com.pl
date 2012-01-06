#!/usr/bin/perl -w
#Thu Jun 25 15:13:09 2009
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
	my %data;
    $r{base}=$rule_base;
     open FI,"-|","wget -q -O - \"$rule_base\"";
    my @links = get_props("img","thumb",<FI>);
    close FI;
    foreach(@links) {   
#http://b25.photo.store.qq.com/http_imgload.cgi?/rurl4_b=a854fa8faf90f68088edc3e429bd4d2ce2d861fdadd5fa6d24f8677a3298218d4b166b4fbe2f2e7d0c6481dbd3c7031e436f62a7ddaf44ec0698f2500f32a2db7cb405291ad4d3c293aca823728f9aa8b818bbfa&amp;a=25&amp;b=25
            if($_ =~ m/http_imgload\.cgi\?/) {
                $data{$_}=1;
            }
    }
    close FI;
    if($r{work_dir}) {
        $r{work_dir} =~ s/\s*-.*$//;
    }
	push @{$r{data}},keys %data;
    return %r;
}
1;
