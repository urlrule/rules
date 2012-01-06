#!/usr/bin/perl -w
#http://game.163.com/photoview/3PGQ0031/9980.html
#Thu Aug  5 21:12:44 2010
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
use utf8;
sub _process {
    my ($url,$rule,$html) = @_;
    my $title = undef;
    my @data;
    my @pass_data;
    my @html = split(/\n/,$html);
    foreach(@html) {
        if((!$title) and m/<title>([^<]+)_网易游戏频道</) {
            $title = $1;
        }
        elsif(m/<i title="img">([^<]+)<\/i>/) {
            push @data,$1;
        }
    }
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
    my %rule = %{shift(@_)};
    my $http = MyPlace::HTTPGet->new();
    my (undef,$html) = $http->get($url,'charset:gb2312');
    return &_process($url,\%rule,$html);
}



#       vim:filetype=perl
1;
