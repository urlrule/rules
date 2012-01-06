#!/usr/bin/perl -w
#http://www.tuzhan.com/search.html?sokey=%E5%88%98%E5%AD%90%E7%92%87&x=24&y=13&size=&width=&height=&extension=&exif=&camera=&color=&page=10
#Mon Aug 16 23:58:08 2010
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
# urlrule_quick_parse($url,$rule,$data_exp,$data_map,$pass_exp,$pass_map,$charset)
# urlrule_parse_data($url,$rule,$data_exp,$data_map,$charset)
# urlrule_parse_pass_data($url,$rule,$pass_exp,$pass_map,$charset)
#================================================================

#
#sub apply_rule {
# return urlrule_quick_parse($_[0],$_[1],$data_exp,$data_map,$pass_exp,$pass_map,$charset);
# return urlrule_parse_data($_[0],$_[1],$data_exp,$data_map,$charset);
# return urlrule_parse_pass_data($_[0],$_[1],$pass_exp,$pass_map,$charset);
# return (
#       '#use quick parse'=>1,
#       'data_exp'=>undef,
#       'data_map'=>undef,
#       'pass_exp'=>undef,
#       'pass_data'=>undef,
#       'charset'=>undef
# );
#}


use MyPlace::HTTPGet;
#use MyPlace::HTML;
use URI::Escape;
sub _process {
    my ($url,$rule,$html) = @_;
    my $title = undef;
    my @data;
    my @pass_data;
    my $count = 0;
    while($html =~ m/<a href="javascript:goPage\('(\d+)'\)"/g) {
        $count=$1 if($1 > $count);
    }
    push @pass_data,$url;
    if($url =~ m/sokey=([^&]+)/) {
        $title = uri_unescape($1);
    }
    if($count>1) {
        $url =~ s/&page=\d+//;
        push @pass_data, map "$url&page=$_",(2 .. $count);
    }
    #my @html = split(/\n/,$html);
    return (
        count=>scalar(@data),
        data=>[@data],
        pass_count=>scalar(@pass_data),
        pass_data=>[@pass_data],
        base=>$url,
        no_subdir=>1,
        work_dir=>$title,
    );
}

sub apply_rule {
    my $url = shift(@_);
    my $rule = shift(@_);
    my $http = MyPlace::HTTPGet->new();
    my (undef,$html) = $http->get($url);
    return &_process($url,$rule,$html,@_);
}



#       vim:filetype=perl
1;
