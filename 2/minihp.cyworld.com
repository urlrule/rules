#!/usr/bin/perl -w
#http://minihp.cyworld.com/svcs/MiniHp.cy/photoLeft/40442043?tid=40442043&urlstr=phot&seq=
#Sun Nov 28 03:14:49 2010
use strict;


#http://minihp.cyworld.com/pims/board/image/imgbrd_list.asp?tid=40442043&urlstr=phot&list_type=2&board_no=52

use MyPlace::Curl;
#use MyPlace::HTML;

my $host = 'http://minihp.cyworld.com/pims/board/image/imgbrd_list.asp?urlstr=phot&list_type=2';
#&board_no=52
sub _process {
    my ($url,$rule,$html) = @_;
    my $title = undef;
    my @data;
	my @pass_name;
    my @pass_data;
	my $tid;
	if($url =~ m/photoLeft\/(\d+)\?/) {
		$tid = $1;
	}
	else {
		return undef;
	}
	$host = $host . "&tid=$tid";
    my @html = split(/\n/,$html);
	foreach(@html) {
		if(m/:InframeNavi\('(\d+)','\d+'\)[^>]+>\s*([^<>\n\r]+)\s*/) {
			my $board_no=$1;
			my $name = $2;
			push @pass_data, $host  . '&board_no=' . $board_no;
			push @pass_name,$name;
		}

	}
    return (
        count=>scalar(@data),
        data=>[@data],
        pass_count=>scalar(@pass_data),
        pass_data=>[@pass_data],
		pass_name=>[@pass_name],
        base=>$url,
        work_dir=>$title,
    );
}

sub apply_rule {
    my $url = shift(@_);
    my $rule = shift(@_);
    my $http = MyPlace::Curl->new();
    my (undef,$html) = $http->get($url,'charset:euc-kr');
    return &_process($url,$rule,$html,@_);
}
=cut

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
# 
# $result{same_level}    : Keep same rule level for passing down
# $result{level}         : Specify rule level for passing down
#================================================================

#       vim:filetype=perl
