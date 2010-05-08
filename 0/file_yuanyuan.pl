#!/usr/bin/perl -w
#file_yuanyuan
#Fri Aug 29 20:59:51 2008
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
    my $url=shift;
    my %rule=%{shift(@_)};
    my $file=$rule{"local_path"};
    my %r;
    my $dirname = qx/dirname "$file"/;
    chomp($dirname);
    open FI,"-|","cat $file | gb2utf";
    while(<FI>) {
        if(/\<A\s*HREF=([^\>\<\s]+\.txt)\s*[^\>\<]*\>([^\<\>]+)\</i) {
            push @{$r{data}},[ "$dirname/$1","$2.txt" ];
        }
    }
    close FI;
    $r{no_subdir}=1;
    $r{hook}=1;
    return %r;
}
sub process_data {
    my $item = shift;
    if($item) {
        my ($src,$dst) = @{$item};
        if (-f $src) {
            unless(system("cp",,"--",$src,$dst)) {
                return "$src->$dst\n";
            }
            return "$!\n";
        }
        else {
            return "File not exists:$src\n";
        }
    }
    return undef;
}

