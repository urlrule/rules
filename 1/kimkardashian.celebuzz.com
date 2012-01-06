#!/usr/bin/perl -w
#http://kimkardashian.celebuzz.com/photo-shoots/
#Sat May 22 04:52:03 2010
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

sub _process_cat {
    my($url,$html,$cats,$albums) = @_;
    my @html = split(/\n/,$html);
    foreach(@html) {
        if(/\/(page\/\d+)/) {
            if(!$cats->{$1}) {
                $cats->{$1}=1;
                my $http = MyPlace::HTTPGet->new();
                app_message "Process $url$1\n";
                my (undef,$data) = $http->get("$url$1");
                &_process_cat($url,$data,$cats,$albums);
            }
        }
        elsif(/href\s*=\s*"([^"]+\/\d+\/\d+\/\d+\/[^"]+\/)"/) {
            print STDERR "Get $1\n";
            $albums->{$1}=1;
        }
    }
}


sub _process {
    my ($url,$rule,$html) = @_;
    my @data;
    my @pass_data;

    my %cats;
    my %albums;

    my $base = $url;
    $base =~ s/\/page\/\d+\//\//;
    $cats{"page/1/"}=1;

    &_process_cat($base,$html,\%cats,\%albums);
    return (data=>[@data],pass_data=>[keys %albums],base=>$url,no_subdir=>1,work_dir=>undef);
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
