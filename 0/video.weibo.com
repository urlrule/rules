#!/usr/bin/perl -w

#DOMAIN : video.weibo.com
#AUTHOR : eotect <eotect@myplace>
#CREATED: 2015-03-14 18:32
#UPDATED: 2015-03-14 18:32
#TARGET : http://video.weibo.com/show?fid=1034:5750c5ca8e4140d226571eeb59e38421

use strict;
no warnings 'redefine';


=method1
sub apply_rule {
 return (
 #Set quick parsing method on
       '#use quick parse'=>1,

#Specify data mining method
       'data_exp'=>undef,
       'data_map'=>undef,

#Specify data mining method for nextlevel
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,

#Specify pages mining method
       'pages_exp'=>undef,
       'pages_map'=>undef,
       'pages_pre'=>undef,
       'pages_suf'=>undef,
       'pages_start'=>undef,
	   'pages_limit'=>undef,

       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
 );
}
=cut

use MyPlace::URLRule::Utils qw/get_url/;
use URI::Escape;

sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
	my $saveas;
	if($url =~ m/title=([^&\/]+)/) {
		$saveas = $1;
	}
	my %info;

	$info{count} = 0;
	if($html =~ m/flashvars="list=([^"&]+)/) {
		$info{playlist_url} = uri_unescape($1);
		my $vhtml = get_url($info{playlist_url},'-v');
		$info{playlist} = $vhtml;
		$info{data} = [];
		foreach(split(/[\r\n]/,$vhtml)) {
			if(m/^\/?([^\/]+\.mp4)$/) {
				$info{video} = 'http://us.sinaimg.cn/' . $1;
				if($saveas) {
					$info{video} .= "\t${saveas}_$1";
				}
				push @{$info{data}},$info{video};
				$info{count}++;
			}
		}
		if(!$info{count}) {
			$info{error} = "No video found on page: $url\n";
		}
	}
	else {
		$info{error} = "Failed parse page: $url\n";
	}
    return %info;
}

=cut

1;

__END__

#       vim:filetype=perl



