#!/usr/bin/perl -w
#http://qzone.qq.com
#Thu Jun 10 23:00:28 2010
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


use MyPlace::HTTPGet;
#use MyPlace::HTML;

sub _process {
    my ($url,$rule,$html) = @_;
    my @data;
    my @pass_data;

    my $uin = $url;
    $uin =~ s/^[^\/]*\/\///;
    $uin =~ s/\..*$//;

    push @pass_data, 
         (
            "http://alist.photo.qq.com/fcgi-bin/fcg_list_album?uin=$uin&outstyle=2",

            "http://xalist.photo.qq.com/fcgi-bin/fcg_list_album?uin=$uin&outstyle=2" 
         );

    return (data=>[@data],pass_data=>[@pass_data],base=>$url,no_subdir=>1,work_dir=>$uin);
}

sub apply_rule {
    my $url = shift(@_);
    my %rule = %{shift(@_)};
    my $http = MyPlace::HTTPGet->new();
    my (undef,$html) = $http->get($url);
    return &_process($url,\%rule,$html);
}



#       vim:filetype=perl
1;
