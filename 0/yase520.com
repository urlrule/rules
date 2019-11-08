#!/usr/bin/perl -w
#DOMAIN : yase520.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2019-02-03 03:52
#UPDATED: 2019-02-03 03:52
#TARGET : https://yase520.com/player/981761
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_yase520_com;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

=method1
sub apply_rule {
	my $self = shift;
	return $self->apply_quick(
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
	   'pages_limit'=>undef,
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
	);
}
=cut

use MyPlace::URLRule::Utils qw/get_url extract_title url_getname url_getinfo url_getfull/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $rurl = $url;
	$rurl =~ s/\/video-(\d+)/\/player\/$1/;
	$rurl =~ s/\/player\//\/video-/;
	#$rurl =~ s/\/\/[^\/]*yase520\.com/\/\/www.yase9.com/;
	#$rurl =~ s/\/\/www\.yase9\.com/\/\/www2.yasedd.com/;
	$rurl =~ s/:\/\/[^\/]+/:\/\/9.yasedd1.com/;
	my $html = get_url($rurl,'-v');
    my $title = undef;
    my @data;
	my %info;
	my @html = split(/\n/,$html);
	my($base,$path,$name) = url_getinfo($url);
	$info{filename} = $name;
	foreach(@html) {
		if(m/property="og:([^"]+)"[^>]+content="([^"]+)/) {
			$info{$1} = $2;
		}
		if(m/(source|poster)\s*:\s*'([^']+)/) {
			$info{$1} = $2;
		}
		if(m/m3u8_url\s*=\s*'([^']+)'/) {
			$info{source} = $1;
		}
		if(m/poster_url\s*=\s*'([^']+\.jpg)/) {
			$info{poster} = $1;
		}
		if(m/video_buyVideo="([^"]+)/) {
			$info{title} = $1;
		}
		last if($info{poster} and $info{title});
	}
	return (error=>"Error parsing page") unless($info{source});
	if($info{source} =~ m/\/\/\[domain_/) {
		$info{source} =~ s/\[domain_dan\]/hone.yyhdyl.com/;
		$info{source} =~ s/\[domain_shuang\]/htwo.yyhdyl.com/;
		$info{source} =~ s/\[domain_three\]/head.yyhdyl.com/;
		$info{source} =~ s/\[domain_fourth\]/head2.yyhdyl.com/;
	}
	else {
		$info{source} =~ s/\/[^\/]+$/\/hls\/hls.m3u8/;
	}
	if($info{source} =~ m/m3u8/) {
		my $data = get_url($info{source},-v);
		print $data,"\n";
		foreach(split(/\n/,$data)) {
			next if(m/^#/);
			$info{source} = url_getfull($_,$info{source});
			last;
		}
	}
	$info{filename} = $info{title};
	$info{filename} =~ s/\s*-([^-]+)$//;
	$info{filename} = extract_title($info{filename});

		foreach($info{source},$info{poster}) {
			s/&amp;/&/g;
			my $src = $_;
			$src = url_getfull($src,$url,$base,$path);
			my $ext = url_getname($src);
			if($src =~ m/\/([^\/]+\.[^\.\/\?]+)$/) {
				$ext = "_$1";
			}
			else {
				$ext = ".mp4";
			}
			$ext =~ s/\.m3u8$/\.ts/;
			push @data,$src . "\t" . $info{filename} . $ext;
		}
    return (
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
		page=>\%info,
    );
}

return new MyPlace::URLRule::Rule::0_yase520_com;
1;

__END__

#       vim:filetype=perl


