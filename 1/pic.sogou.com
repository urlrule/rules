#!/usr/bin/perl -w
#http://pic.sogou.com/d?query=%D5%C5%DC%B0%D3%E8&mood=0&mode=8&di=2&w=05009900&dr=1&page=2&did=21
#->http://pic.sogou.com/su?k=%D5%C5%DC%B0%D3%E8&tc=1&t=0,2&id=3&d=f0aab8afa5a1c806,b52f3d9fa5a1c806,162fd9ffa5a1c806,1e3b388fa5a1c806,b900f25fa5a1c806,798832cfa5a1c806,9f135fafa5a1c806
#
#Sun Aug 15 01:12:10 2010
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

use MyPlace::LWP;
#use MyPlace::HTML;
sub _process {
    my ($url,$rule,$html) = @_;
    my $title = undef;
    my @data;
    my @pass_data;
    my @ds;
    if($url =~ m/[\?&]query=([^&]+)/) {
        my $query = $1;
        my $preurl = 'http://pic.sogou.com/su?k=$1&tc=1&t=0,2&id=1&d=';
        while($html =~ m/"([^"]+)","NormalSummary"/g) {
            push @ds,$1;
        }
        foreach(@ds) {
            s/\s+/,/g;
            push @pass_data,$preurl . $_ if($_);
        }
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
    my %rule = %{shift(@_)};
    my $http = MyPlace::LWP->new();
    my (undef,$html) = $http->get($url);
    return &_process($url,\%rule,$html);
}



#       vim:filetype=perl
1;
