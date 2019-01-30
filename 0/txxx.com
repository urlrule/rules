#!/usr/bin/perl -w
#DOMAIN : txxx.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
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
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
	my %info;
	if($html =~ m/<a[^>]+href="(.+get_file.+\/[^\/]+\/\?[^"]+)/) {
		$info{url} = $1;
		$info{url} =~ s/&amp;/&/g;
		$info{url} =~ s/download=true/f=video.m3u8/;
		my $lt=time;
		$info{url} =~ s/%lock_time%/$lt/;
		$info{url} =~ s/%lock_ip%/120/;
		$info{url} =~ s/:\/\/www\./:\/\/upload./;
	}
	if((!$info{url})) {
		my @html = split("\n",$html);
		foreach(@html) {
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
	}
	unless($info{pC3} or $info{url}) {
		return (error=>"Error parsing page");
	}
	if(!$info{video_id}) {
		if($url =~ m/\/(?:videos|embed)\/(\d+)/) {
			$info{video_id} = $1;
		}
	}
	return (error=>"Error getting video_id") unless($info{video_id});
	if($info{pC3}) {
		my $param = "$info{video_id},$info{pC3}";
		my $posturl = "https://upload.txxx.com/sn4diyux.php";
		my @post = qw{curl --silent};
		push @post,"--url",$posturl;
		push @post,'--referer',$url;
		push @post,'--form-string',"param=$param";
		print STDERR "<Posting data> $posturl ...\n";
		open FI,'-|',@post;
		while(<FI>) {
			if(m/"video_url"\s*:\s*"([^"]+)"/) {
				$info{enc_url} = $1;
				last;
			}
		}
		close FI;
		if(!$info{enc_url}) {
			return (error=>"Error decoding url");
		}
		use Encode qw/encode/;
		$info{enc_url} = encode("UTF-8",$info{enc_url});#,"utf8");
		my $decoder = locate_file("tools/decode_txxx.com.js");
		if(!-f $decoder) {
			return (error=>"Error locate decoder $decoder");
		}
		print STDERR "Using $decoder\n";
		if(!open FI,'-|','node',$decoder,$info{enc_url}) {
			return (error=>"Error executing decoder");
		}
		my $url = join("",<FI>);
		close FI;
		$info{url} = $url;
	}
	unless($info{url}) {
		return (error=>"Error cracking page");
	}

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
	my $prefix = $info{title} ? $info{title} . "_" : "";
	if($info{image}) {
		push @data,$info{image} . "\t$prefix" . url_getname($info{image});
	}
	push @data,$info{url} . "\t$prefix" . url_getname($info{url});
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


