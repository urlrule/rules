#!/usr/bin/perl -w
#http://www.moko.cc/post/5163.html
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
use MyPlace::URLRule::Utils qw/create_title get_url/;
use MyPlace::LWP;
sub apply_rule {
    my $rule_base= shift(@_);
    my %rule = %{shift(@_)};
    my %r;
	my %data;
    $r{base}=$rule_base;
	my $html = get_url($rule_base,'-v');
    my $title;
    foreach(split('\n',$html)) {
        unless($title) {
            if($_ =~ /<title\s*>([^<>]+?)\s*</i) {
                $title = $1;
                $title =~ s/^[^\|]+\|\s*//;
                $title =~ s/^\s*展示\s*//;
                $title =~ s/(?:\s+|\s*\(\s*\d+\s*\)\s*)$//;
                $r{work_dir}=$title if($title);
            }
        }
		if(m/src2\s*="([^"]+)"/) {
			$data{$1} = 1;
		}
        #elsif($_ =~ m/src\s*=\s*"([^"]*\/users\/\d+[^"]+)"/) 
        #{
        #    my $url = $1;
        #    $url =~ s/\/thumb\//\/src\//;
        #    $data{$url} = 1;
        #}
    }
	push @{$r{data}},keys %data;
    return %r;
}


1;
#   vim:filetype=perl
