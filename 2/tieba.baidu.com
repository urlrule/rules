#!/usr/bin/perl -w
#http://tieba.baidu.com/f?kz=847145683
#Wed Aug  4 21:05:19 2010
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
    my $pre = "";
    my $pages = 1;
    if($url =~ m/\/tupian/) {
        while($html =~ m/href="([^"]*\/tupian\/view\/)(\d+)"/g) {
            $pre = $1 unless($pre);
            $pages = $2 unless($pages > $2);
        }
        if($pages > 1) {
            for(my $i=1;$i<=$pages;$i++) {
                push @pass_data,"$pre$i";
            }
        }
        elsif($url =~ m/\/tupian\/?$/) {
            my $view = $url;
            $view =~ s/\/tupian\/?$/\/tupian\/view\/1/;
            push @pass_data,$view;
        }
        else {
            push @pass_data,$url;
        }
    }
    else {        
        foreach(@html) {
            if(/href="(\/f\?kz=\d+)" target="_blank"/) {
                push @pass_data,$1;
            }
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
    my (undef,$html) = $http->get($url);
    return &_process($url,\%rule,$html);
}



#       vim:filetype=perl
