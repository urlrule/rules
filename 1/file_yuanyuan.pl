#!/usr/bin/perl -w
#file_yuanyuan
#Fri Aug 29 21:25:06 2008
use strict;

#================================================================
# apply_rule will be called,the result returned have these meaning:
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
    my $url=shift(@_);
    my %rule=%{shift(@_)};
    my %r;
    my $file = $rule{local_path};
    my $dirname = qx/dirname "$file"/;
    chomp($dirname);
    open FI,"<",$file;
    while(<FI>) {
        my @match = $_ =~ m/href\s*=\s*(\d+asp\.htm)/gi;
        foreach(@match) {
            push @{$r{pass_data}},"local:$rule{'local'}/$dirname/$_";
        }
    }
    close FI;
    push @{$r{pass_data}},"local:$rule{'local'}/$file";
    $r{no_subdir}=1;
    return %r;
}
