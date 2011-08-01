#!/usr/bin/perl -w
#http://hi.baidu.com/chen497271950/album/%D5%C5%DC%B0%D3%E8
#Sun Aug 15 00:09:20 2010
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
    my $title = undef;
    my @data;
    my @pass_data;
    my @html = split(/\n/,$html);
    my $page = 0;
    foreach(@html) {
        if((!$title) and m/<span id="album_Name">([^<]+)<\/span>/) {
            $title = $1;
        }
        else {
            foreach(m/href="[^"]+\/index\/(\d+)">\[/g) {
                $page = $1 if($1 > $page);
            }
        }
    }
    if($page > 1) {
        @pass_data = map "$url/index/$_",(2 .. $page);
    }
    push @pass_data,$url;

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
    my (undef,$html) = $http->get($url,'charset:gbk');
    return &_process($url,\%rule,$html);
}



#       vim:filetype=perl
