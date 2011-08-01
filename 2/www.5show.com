#!/usr/bin/perl -w
#http://www.5show.com/GirlShow.aspx?fid=5183
#Tue Jul 13 02:08:14 2010
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
    my $url = shift(@_);
    my %rule = %{shift(@_)};
    my $fid;
    my @pass_data;
    if($url =~ /fid=(\d+)/) {
        $fid = $1;
    }
    elsif($url =~ /_fid_(\d+)\./) {
        $fid = $1;
    }
    if($fid) {
        for my $index (0 .. 10) {
            push @pass_data,"/ajax_Album.aspx?fid=$fid&pageindex=$index&t=2";
        }
    }
    return (
        count=>0,
        pass_count=>scalar(@pass_data),
        pass_data=>[@pass_data],
        base=>$url,
        no_subdir=>1,
    );
}



#       vim:filetype=perl
