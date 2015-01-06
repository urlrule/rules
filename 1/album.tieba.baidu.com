#!/usr/bin/perl -w
#http://tieba.baidu.com/p/2067100822
#Wed Aug  4 21:02:45 2010
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
sub apply_rule {
    my $url = shift(@_);
    my %rule = %{shift(@_)};
    my $http = MyPlace::LWP->new();
	my $rurl = $url;
	$rurl =~ s/\/\/album\.tieba/\/\/tieba/;
    my (undef,$html) = $http->get($rurl);
#	'http://tieba.baidu.com/photo/g/bw/picture/list?kw=%E5%85%A8%E5%AD%9D%E7%9B%9B&alt=jview&rn=200&tid=3466741983&pn=1&ps=1&pe=9999&info=1&_=1420570220929'

	my %info = (
		kw=>'',
		alt=>'jview',
		rn=>'200',
		tid=>'',
		pn=>'1',
		ps=>'1',
		pe=>'9999',
		info=>'1',
		_=>scalar(localtime),
	);
	my $title;
	if($html =~ m/fname="([^"]+)/) {
		$info{kw} = $1;
	}
	if($html =~ m/thread_id\s*:(\d+)/) {
		$info{tid} = $1;
	}
	if($html =~ m/title\s*:\s*"([^"]+)/) {
		$title = $1;
	}
	my $nurl = 'http://tieba.baidu.com/photo/g/bw/picture/list?';
	$nurl .= join("&",map "$_=$info{$_}",keys %info);
	return (
		info=>\%info,
		count=>0,
		pass_count=>1,
		pass_data=>[$nurl],
		title=>$title,
	);
}



#       vim:filetype=perl
1;
