#!/usr/bin/perl -w
#DOMAIN : txxx.com
#AUTHOR : eotect <eotect@MYPLACE>
#CREATED: 2019-01-28 02:28
#UPDATED: 2019-01-28 02:28
#TARGET : https://www.txxx.com/videos/65188/darryl-hannah/?fr=65188
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_txxx_com;
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

use MyPlace::URLRule::Utils qw/get_url create_title url_getname/;
use MyPlace::URLRule qw/locate_file/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	$url =~ s/^([^\/]+)\/\/txxx\.com/$1\/\/txxx.com/;
	$url =~ s/\/\/[^\/]*tubepornclassic\.com/\/\/tubepornclassic.com/;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
	my %info;
	if($html =~ m/<a[^>]+href="(.+get_file.+\/[^\/]+\/\?[^"]+)/) {
		$info{video_src} = $1;
		$info{video_src} =~ s/&amp;/&/g;
		$info{video_src} =~ s/download=true/f=video.m3u8/;
		my $lt=time;
		$info{video_src} =~ s/%lock_time%/$lt/;
		$info{video_src} =~ s/%lock_ip%/120/;
		$info{video_src} =~ s/:\/\/www\./:\/\/upload./;
	}
		my @html = split("\n",$html);
		foreach(@html) {
			if(m/video_url\s*=\s*"([^"]+)"/) {
				$info{enc_url} = $1;
			}
			if(m/video_url\s*\+=\s*"([^"]+)/) {
				$info{vurl2} = $1;
			}
			next unless(m/^\s*[\w\d]+\s*:/);
			while(m/\b([\w\d]+)\b\s*:\s*'([^']+)'/g) {
				$info{$1} = $2;
			}
			while(m/\b([\w\d]+)\b\s*:\s*"([^"]+)"/g) {
				$info{$1} = $2;
			}
			while(m/\b([\w\d]+)\b\s*:\s*(\d+)/g) {
				$info{$1} = $2;
			}
		}
	unless($info{pC3} or $info{video_src} or $info{enc_url}) {
		return (error=>"Error parsing page",page=>\%info);
	}
	if(!$info{video_id}) {
		if($url =~ m/\/(?:videos|embed)\/(\d+)/) {
			$info{video_id} = $1;
		}
	}
	return (error=>"Error getting video_id",page=>\%info) unless($info{video_id});
	if(!$info{title}) {
		if($html =~ m/<h2[^>]*>(.+?)<\/\s*h2/) {
			$info{title} = $1;
			$info{title} =~ s/<[^>]+>//g;
			$info{title} = create_title($info{title});
		}
	}
	else {
		$info{title} = create_title($info{title});
	}

	return create_data($url,$title,\%info) if($info{video_src});


	if(!$info{enc_url}) {
		my $param = "$info{video_id},$info{pC3}";
		my $posturl = "https://getfile.txxx.com/sn4diyux.php";
		my @curl = qw{curl --silent};
		my @post=('--referer',$url);
		push @post,'--form-string',"param=$param";
		print STDERR "<Posting data> $posturl ...\n";
		print STDERR join(" ",@post),"\n";
		my $res = get_url($posturl,@post);
		if($res =~ m/"video_url"\s*:\s*"([^"]+)"/) {
			$info{enc_url} = $1;
		}
#		open FI,'-|',@curl,"--url",$posturl,@post;
#		while(<FI>) {
#			print STDERR $_;
#			if(m/"video_url"\s*:\s*"([^"]+)"/) {
#				$info{enc_url} = $1;
#				last;
#			}
#		}
#		close FI;
		#die($res);
		if(!$info{enc_url}) {
			return (error=>"Error decoding url",page=>\%info);
		}
	}
		#use Encode qw/encode/;
		#$info{enc_url} = encode("UTF-8",$info{enc_url});#,"utf8");
		my $decoder = locate_file("tools/decode_txxx.com.js");
		if(!-f $decoder) {
			return (error=>"Error locate decoder $decoder",page=>\%info);
		}
		print STDERR "Using $decoder\n";
		if(!open FI,'-|','node',$decoder,$info{enc_url}) {
			return (error=>"Error executing decoder",page=>\%info);
		}
		my $durl = join("",<FI>);
		close FI;
		if($info{vurl2}) {
			my(undef,$dpath,$lip,$lt) = split(/\|\|/,$info{vurl2});
			$durl = $durl . "&lip=$lip&lt=$lt";
			$info{dpath} = $dpath;
		}
		if($info{dpath}) {
			$durl =~ s/([^\/]+)\/[^\/]+\/[^\/]+\/[^\/]+\//$1$info{dpath}/;
		}
		#if($url =~ m/tubepornclassic.com/) {
		#	$durl = $durl . "&f=video.m3u8";
		#}
		$info{video_src} = $durl;

	if(!$info{video_src}) {
		return (error=>"Error cracking page",page=>\%info);
	}
	return create_data($url,$title,\%info);
}
sub create_data {
	my $url = shift;
	my $title = shift;
	my $info = shift;
	my %info = %$info;
	my @data;

	my $prefix = $info{title} ? $info{title} . "_" : "";
	if($info{image}) {
		push @data,$info{image} . "\t$prefix" . url_getname($info{image});
	}
	push @data,$info{video_src} . "\t$prefix" . url_getname($info{video_src});
    return (
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
        title=>$title,
		page=>\%info,
    );
}

return new MyPlace::URLRule::Rule::0_txxx_com;
1;

__END__

#       vim:filetype=perl


