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

use MyPlace::URLRule::Utils qw/get_url strnum/;
use URI::Escape;

sub apply_rule {
    my ($url,$rule) = @_;

	if($url =~ m/http:\/\/video\.weibo\.com\/p\/(.+)$/) {
		$url = 'http://weibo.com/p/' . $1;
	}
	elsif($url =~ m/\/player\/([^\/]+)/) {
		$url = 'http://video.weibo.com/show?fid=' . $1;
	}
	my $html = get_url($url,'-v');
	my $saveas;
	if($url =~ m/title=([^&\/]+)/) {
		$saveas = uri_unescape($1);
	}
	my %info;

	$info{count} = 0;
#	print STDERR $html,"\n";

	my $vhtml;
	if($html =~ m/action-data="([^"]+)"/) {
		$vhtml = $1;
		foreach(split("&",$vhtml)) {
			if(m/^([^=]+)=(.+)$/) {
				$info{$1} = uri_unescape($2);
			}
		}
		if($info{video_src}) {
			$vhtml = $info{video_src};
			$vhtml =~ s/^.*?:?\/\//http:\/\//;
			$info{playlist_url} = $vhtml;
		}
		$info{prefix} = "";
		foreach(($info{uid},$info{mid},$info{fnick})) {
			$info{prefix} = $info{prefix} . $_ . "_" if($_);
		}
		$info{cover} = $info{cover_img} if($info{cover_img});
	}
	elsif($html =~ m/file=([^"&]+\.m3u8[^"&]*)/) {
		$info{playlist_url} = uri_unescape($1);
		$vhtml = get_url($info{playlist_url},'-v');
	}
	elsif($html =~ m/flashvars=\\"file=(http[^"&]+)(?:\\"|&)/) {
		$vhtml = uri_unescape($1);
		$info{playlist_url} = $vhtml;
	}
	elsif($html =~ m/flashvars\s*=\s*"file=(http[^"&]+)["&]/) {
		$vhtml = uri_unescape($1);
		$info{playlist_url} = $vhtml;
	}
	elsif($html =~ m/video_src=([^&]+)/) {
		$vhtml = $1;
		$vhtml = uri_unescape($1);
		$vhtml =~ s/^.*?:?\/\//http:\/\//;
		$info{playlist_url} = $vhtml;
	}
	if($vhtml) {
		$info{playlist} = $vhtml;
		foreach(split(/[\r\n]/,$vhtml)) {
			s/^http:\/\/us\.sinaimg\.cn\/?//;
			if(m/^(.*?)([^\/]+)(\.mp4)$/) {
				$info{video} = $_;
				$info{filename} = $info{prefix} . $2 if($2);
				$info{ext} = $3;
			}
			elsif(m/^(.*?)([^\/]+)(\.mp4)(\?[^\/]+)$/) {
				$info{video} = $_;
				$info{filename} = $info{prefix} . $2 if($2);
				$info{ext} = $3;
			}
			my $sufx = '';
			if($info{count}>0) {
				$sufx = "_" .  strnum($info{count} + 1,3);
			}
			if($info{video}) {
				if($info{video} !~ /^http/) {
					$info{video} =~ s/^\/+//;
					$info{video} = 'http://us.sinaimg.cn/' . $info{video};
				}
				if($saveas) {
					$info{video} .= "\t${saveas}$sufx$info{ext}";
					$info{cover} .= "\t${saveas}$sufx.jpg" if($info{cover});
				}
				else {
					$info{video} .= "\t$info{filename}$sufx$info{ext}";
					$info{cover} .= "\t$info{filename}${sufx}.jpg" if($info{cover});
				}
				push @{$info{data}},$info{video};
				push @{$info{data}},$info{cover} if($info{cover});
				$info{count} = scalar(@{$info{data}});
				delete $info{video};
			}
		}
		if(!$info{count}) {
			$info{error} = "No video found on page: $url\n";
		}
	}
	elsif($html =~ m/video_src=([^&]+)/){
		$info{video} = uri_unescape($1);
		$info{video} =~ s/^:?\/\//http:\/\//;
		push @{$info{data}},$info{video}  . "\t$saveas.mp4";
		if($html =~ m/cover_img=([^&]+)/) {
			$info{cover} = uri_unescape($1);
			$info{cover} =~ s/^:?\/\//http:\/\//;
			push @{$info{data}},$info{cover}  . "\t$saveas.jpg";
		}
	}
	else {
		$info{error} = "Failed parse page: $url\n";
	}
	if($info{data}) {
		$info{download} = $info{data};
	}
    return %info;
}

=cut

1;

__END__

#       vim:filetype=perl



