#!/usr/bin/perl -w
#http://blog.163.com/imjihye_fans
#Thu Aug 19 01:44:40 2010
use strict;

use MyPlace::LWP;
use MyPlace::163::Blog;
#use MyPlace::HTML;

sub _process {
    my ($url,$rule,$html) = @_;
    my $title = undef;
    my @data;
    my @pass_data;
	if($html =~ m/userId:(\d+).+?userName:'([^']+)'/) {
		my $id = $1;
		my $name = $2;
		my $hd = new MyPlace::163::Blog;
		$hd->{id} = $id;
		$hd->{name} = $name;
		my $blogs = $hd->get_blogs;
		if($blogs) {
			push @pass_data,@{$blogs};
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
