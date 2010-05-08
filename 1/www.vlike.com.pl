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
use MyPlace::HTML;

sub get_sub_items  {
    my $rule_base=shift;
    open FI,"-|","netcat \"$rule_base\"";
    my @links = get_props("a","href",<FI>);
    close FI;
    my %data;
    foreach(@links) {
        if($_ =~ m/\/pic\/.*index.html$/) {
            $data{$_}=1;
        }
	}

    return keys %data;
}

sub apply_rule {
    my $rule_base= shift(@_);
    my %rule = %{shift(@_)};
    my %r;
	my %data;
    $r{base}=$rule_base;
    my $id="unknown";
    if($rule_base =~ m/\/pic\/([^\/]+)/) {
        $id = $1;
        $r{work_dir}=$id;
    }
    open FI,"-|","netcat \"$rule_base\"";
    my @links = get_props("a","href",<FI>);
    close FI;
    
    my $count=0;
    foreach(@links) {
        if($_ =~ m/(\d+)\.html$/){
            if($1>$count) {
                $count=$1;
            }
        }
        elsif($_ =~ m/\/pic\/.*index.html$/) {
            $data{$_}=1;
        }
	}
    push @{$r{pass_data}},keys %data;
    warn("Count=$count\n");
    foreach my $idx(2..$count) {
        push @{$r{pass_data}},get_sub_items("http://www.vlike.com/pic/$id/$idx.html");
    }
    $r{no_subdir}=1;
    return %r;
}
