#!/usr/bin/perl -w
#http://wpf6188.tuzhan.com/album/410d2a8586ab0c01.html
#Mon Aug 16 21:52:58 2010
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
    my $count = 0;
#    my @html = split(/\n/,$html);
#    foreach(@html) {
#        if((!$title) and m/<a href="\/album.html">[^<]+<\/a>&nbsp;&raquo;&nbsp;([^<]+)/) {
#            $title = $1;
#        }
#        else{
#            while(m/<a href="javascript:goPage\('(\d+)'/g) {
#                $count = $1 if($1 > $count);
#            }
#        }
#    }
            while($html =~ m/<a href="javascript:goPage\('(\d+)'/g) {
                $count = $1 if($1 > $count);
            }
    if($count > 1) {
        @pass_data = map "$url?page=$_",(2 .. $count);
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
    return &_process($url,\%rule,$html);
}



#       vim:filetype=perl
1;
