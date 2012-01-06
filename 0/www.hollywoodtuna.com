#!/usr/bin/perl -w
#http://www.hollywoodtuna.com/?cat=77
#Sun May 23 03:23:28 2010
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
use MyPlace::HTML;

sub _process {
    my ($url,$rule,$html,$status) = @_;
    my @data;
    my @pass_data;
    $status = {} unless($status);
    my @href = get_hrefs($html);
    foreach(@href) {
        s/(?:\&amp;|\&#38;)/\&/g;
#        print $_,"\n";
        if(/([^"]*)\/photo(\d*)\.php\?id=([^"\&]+)\&[^"]+loc=(\d+)/) {
            push @data,"$1/images$4/bigimages$4/$3.jpg";
        }
        elsif(/([^"]*)\/photo(\d*)\.php\?id=([^"\&]+)\&/) {
            push @data,"$1/images/bigimages$2/$3.jpg";
        }
        elsif(/paged=(\d+)/) {
            next if($status->{$1});
            $status->{$1}=1;
            my $page = "$url&paged=$1";
            my $http = MyPlace::HTTPGet->new();
            app_message "processing $page...\n";
            my (undef,$htmlpage) = $http->get($page);
            my %r = &_process($url,$rule,$htmlpage,$status);
            push @data,@{$r{data}} if($r{data});
        }
    }
    return (data=>[@data],pass_data=>[@pass_data],base=>$url,no_subdir=>1,work_dir=>undef);
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
