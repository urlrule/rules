#!/usr/bin/perl -w
#http://page.renren.com/600010359/album/375469813
#Wed Aug  4 19:40:03 2010
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
use Encode;
my $utf8 = find_encoding("utf8");
#use MyPlace::HTML;

sub _process {
    my ($url,$rule,$html) = @_;
    my $title = undef;
    my @data;
    my @pass_data;
    my $prefix = "";
    my $page = 0;
    my @html = split(/\n/,$html);
    foreach(@html) {
        if((!$title) and /<h3[^>]+>([^<]+)</) {
            $title = $1;
        }
        if(m/(\/\d+\/album\/\d+)\?curpage=(\d+)/) {
            $prefix = "$1?curpage=" unless($prefix);
            $page = $2 if($2 > $page);
        }
    }
    if($page>0) {
        @pass_data = map $prefix . $_,(1 .. $page);
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
    my (undef,$html) = $http->get($url);
    return &_process($url,\%rule,$utf8->decode($html));
}



#       vim:filetype=perl
1;
