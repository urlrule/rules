#!/usr/bin/perl -w
#DOMAIN : fi11.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2020-02-24 00:28
#UPDATED: 2020-02-24 00:28
#TARGET : https://www.hxcpp4.com/tag.aspx?AgentID=0&tag=%E6%8A%96%E9%9F%B3
#URLRULE: 2.0
package MyPlace::URLRule::Rule::1_fi11_com;
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

use MyPlace::WWW::Utils qw/get_url decode_title get_safename url_getname/;
use MyPlace::JSON;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
	my ($api_url,@header) = (
		'https://www.cthxc.com/Video/GetList',
		'--header','Content-Type: application/json;charset=utf-8',
		"--referer",$url,
	);
	my $data = sub {
		my $key = shift;
		my $value = shift;
		my $page = shift(@_) || 1;
		my $post = {
			length=>20,
			start=>($page-1)*20,
			ClientType=>1,
			$key=>$value,
		};
		#$post->{searchtext} = "" unless($post->{searchtext});
		return ("-d",encode_json($post));
	};
	my $ajax = sub {
		my $key = shift;
		my $value = shift;
		my $page = shift;
		my @args = (@header,&$data($key,$value,$page));
		print STDERR join(" ",$api_url,"-v",@args),"\n";
		my $data = get_url($api_url,"-v",@args);
		return decode_json($data);
	};
	my $name;
	my $base;
	my $key;
	my $value;
	if($url =~ m/^(https?:\/\/[^\/]+)\/.*[&\?]type=(\d+)/) {
		$key = "TypeID";
		$value = "$2";
		$base = $1;
		$name = $value;
	}
	elsif($url =~ m/^(https?:\/\/[^\/]+)\/.*[&\?]tag=([^&]+)/) {
		require Encode;
		my $utf8 = Encode::find_encoding('utf-8');
		$key = "searchtext";
		$value = $utf8->decode($2);
		$base = $1;
		$name = $2;
	}
	elsif($url =~ m/^(https?:\/\/[^\/]+)\/.*[&\?]AlbumID=([^&]+)/) {
		$key = "AlbumID";
		$value = "$2";
		$base = $1;
		$name = $2;
		$api_url = 'https://www.cthxc.com/Common/GetAlbumVideoList';
	}
	if($url =~ m/[&\?]Name=([^&]+)/) {
		$name = $1;
	}
	if(!$value) {
		return (error=>"NO information can get from URL");
	}
	my $info = &$ajax($key,$value);
	if(!ref $info) {
		return (error=>"Failed process url");
	}
	my $total = $info->{recordsTotal};
	my $pages = int($total/20)+1;
	$pages = $pages - 1 if($total%20 == 0);
	if($pages < 1) {
		return (error=>"No data found",info=>$info);
	}
	my @videos;
	my $page = 1;
	while($page<=$pages) {
		$page++;
		next unless(ref $info);
		next unless(ref $info->{data});
		foreach(@{$info->{data}}) {
			push @videos,$_;
		}
		print STDERR "[$page/$pages] Geting page $page ...\n";
		$info = &$ajax($key,$value,$page);
	}
	my @data;
	my @pass_data;
	foreach my $info(@videos) {
		my $title = decode_title($info->{Name},'utf8');
		my $id = $info->{ID};
		$title = $title ? $id . "_" . $title : $id;
		$title =~ s/【含羞草.*】|含羞草推荐：//g;
		push @data,"urlrule:$base/player.aspx?math=1&id=$id\t$title.ts";
		if($info->{CoverImgUrl}) {
			push @data,$info->{CoverImgUrl} . "\t" . $title . ".jpg";
		}
	}
    #my @html = split(/\n/,$html);
    return (
        base=>$url,
        count=>scalar(@data),
        data=>\@data,
		pass_data=>\@pass_data,
		pass_count=>scalar(@pass_data),
    );
}

return new MyPlace::URLRule::Rule::1_fi11_com;
1;

__END__

#       vim:filetype=perl


