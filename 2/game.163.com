#!/usr/bin/perl -w
#http://game.163.com/special/00314J4D/Showgirl_list.html
#Thu Aug  5 21:44:34 2010
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
    my %pass_data;
    my $base = $url;
    $base =~ s/\.html$//;
    my $base_len = length($base);
    while($html =~ m/href\s*=\s*"([^"]+)"/g) {
        my $href = $1;
        if(substr($href,0,$base_len) eq $base) {
            $pass_data{"$href"}=1;
        }
    }
    $pass_data{"$url"} = 1;
    return (
        count=>scalar(@data),
        data=>[@data],
        pass_count=>scalar(keys %pass_data),
        pass_data=>[keys %pass_data],
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
1;
