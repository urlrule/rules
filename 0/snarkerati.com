#!/usr/bin/perl -w
#http://snarkerati.com/galleries/index.php/Kirsty-Gallacher
#Fri May 21 18:06:24 2010
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
    open FI,"-|","netcat \'$rule_base\'";
    while(<FI>) {
        foreach($_ =~ m/(\/galleries\/index\.php\/[^"\/]+\/[^"\/]+)\?action=thumb"/g) {
            s/\/index\.php//;
            push @{$r{data}},$_;
        }
    }
    close FI;
    return %r;
}


#       vim:filetype=perl
1;
