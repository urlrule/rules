#!/usr/bin/perl -w
#http://www.hankyung.com/autoplus/racingmodel_profile_view.php?no=106&flag=&cmt_page=1&page=7
#Thu Aug 19 20:57:27 2010
use strict;


use MyPlace::LWP;
#use MyPlace::HTML;

sub _process {
    my ($url,$rule,$html) = @_;
    my $title = undef;
    my @data;
    my @pass_data;
    my $pre = "";
    my $suf = "";
    my $count = 0;
    while($html =~ m/href="([^"]+&page=)(\d+)([^"]*)"/g) {
        if($2 > $count) {
            $count = $2;
            $pre = $1 if($1);
            $suf = $3 if($3);
        }
    }
    if($count > 2) {
        @pass_data = map "$pre$_$suf",(2 .. $count);
    }
    push @pass_data,$url;
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
    my $http = MyPlace::LWP->new();
    my (undef,$html) = $http->get($url);
    return &_process($url,$rule,$html,@_);
}


1;

__END__

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

#       vim:filetype=perl
1;
