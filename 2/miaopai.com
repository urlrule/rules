#!/usr/bin/perl -w
#http://www.miaopai.com/u/paike_fnusu5tuah
#Mon Jan  5 01:21:48 2015
use strict;
no warnings 'redefine';


=method1
sub apply_rule {
 return (
       '#use quick parse'=>1,
       'data_exp'=>undef,
       'data_map'=>undef,
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,
       'pages_exp'=>undef,
       'pages_map'=>undef,
       'pages_pre'=>undef,
       'pages_suf'=>undef,
       'pages_start'=>undef,
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
 );
}
=cut

use MyPlace::URLRule::Utils qw/get_url/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $rurl = $url;
	my $uid;
	if($url =~ m/(.*\/u)\/([^\/]+)\/?$/) {
		$rurl = "$1/$2/relation/follow.htm";
		$uid = $2;
	}
	my $html = get_url($rurl,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
    my @html = split(/\n/,$html);
	my %info = (
			url=>'/gu/u',
			suids=>'',
			fen_type=>'channel',
			uid=>'',
			uname=>'',
		);
	foreach(@html) {
		if((!$info{uid}) and m/<h1><a[^>]+title="([^"]+)"[^>]+href="([^"]+)\/u\/([^"\?\&\/]+)/) {
			$info{uname} = $1;
			$info{host} = $2;
			$info{uid} = $3;
		}
		#elsif(m/var\s+maxnum\s*=\s*(\d+)/) {
		#	$info{pages} = $1;
		#}
		elsif(m/<li><b><a title="视频"[^>]+>(\d+)视频/) {
			if($1>0) {
				$info{pages} = int(($1-1)/4)+1;
			}
			else {
				$info{pages} = 0;
			}
		}
		elsif(m/var\s+(url|suids|fen_type)\s*=["']([^"']+)["']/) {
			$info{$1} = $2;
		}
		elsif(m/<div class="video_img">/) {
			last;
		}
	}
	if(!($info{pages} and $info{url} and $info{suids} and $info{fen_type})) {
		return (error=>"parsing page failed");
	}
	$info{url} = '/gu/u';
	@pass_data = map "$info{host}$info{url}?page=$_&suid=$info{suids}&fen_type=$info{fen_type}",(1 .. $info{pages});
    return (
		info=>\%info,
        count=>0,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$info{uid},
    );
}

=cut

1;

__END__

#       vim:filetype=perl
