#!/usr/bin/perl -w
#http://forum.skins.be/9-hq-celebrity-pictures/549-kirsty-gallacher/
#Fri May 21 17:47:14 2010
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
    $r{base}=$rule_base;
    use MyPlace::LWP;
    my $http= MyPlace::LWP->new();
    $http->cookie_set("key"=>"show_adult",val=>"1",path=>"/",domain=>".skins.be",maxage=>3600*24*30);
    my (undef,$data) = $http->get($rule_base);
    foreach($data =~ m/src\s*=\s*"(http:\/\/\d+thumb\.skins\.be\/[^"]+)"/ig) {
            s/(\d+)thumb/$1img/;
            push @{$r{data}},$_;
    }
    return %r;
}


#       vim:filetype=perl
1;
