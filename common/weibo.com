#!/usr/bin/perl -w
use strict;
use utf8;

use MyPlace::URLRule::Utils qw/get_url get_html strnum new_html_data/;

sub build_page_url {
	my $uid = shift;
	my $pid = shift;
	my $ppid = $pid - 1;
	return "http://weibo.com/p/aj/mblog/mbloglist" .
			"?domain=100505" . 
			"&pre_page=$ppid" .
			"&page=$pid" .
			"&count=15" .
			"&pl_name=Pl_Official_LeftProfileFeed__13" .
			"&id=100505$uid" .
			"&script_uri=/p/100505$uid/weibo" .
			"&feed_type=0" .
			"&from=page_100505" .
			"&mod=TAB" .
			"&__rnd=" . rand(1)*1000000000000;
}

sub process_page {
	my($url,$level,$rule,$page) = @_;
	print STDERR "Retriving page $page...\n";
	my $html = get_html($url);
	$html =~ s/\\(["\\\/])/$1/g;
	$html =~ s/\\n/\n/g;
	$html =~ s/\\t/\t/g;
	$html =~ s/\\r/\r/g;
	my @data;
	my @blocks;
	my @posts;
	#print STDERR $html;
	while($html =~ m/(<div[^>]*tbinfo=[^>]*>.+?)<div node-type="feed_list_repeat"/sg) {
		push @blocks,$1;
	}
	foreach(@blocks) {
		my $post = {};
		my $text = $_;
		#$text =~ s/\s*<[^>]*>\s*//g;
		$text =~ s/[\n\r]//sg;
		if($text =~ m/\\u/) {
			$text =~ s/(["@])/\\$1/sg;
			$text =~ s/\\u(....)/\\x{$1}/sg;
			$text = (eval("\"\" . \"$text\""));
		}
#		if(length($text) > 20) {
#			$text =~ s/^\s*([^，。\.,]+).+$/$1/;
#			$text = substr($text,0,20);
#		}
		$text =~ s/src="([^"]+)\/(?:thumbnail|square)\/([^"]+)"/src="$1\/large\/$2"/sg;
		$post->{text}=$text;
		$post->{images}=[];
		while(m/src="([^"]+)\/(?:thumbnail|square)\/([^"]+)"/sg) {
			my $src = "$1/large/$2";
			if($src =~ m/\.([^\.\/]+)$/) {
				push @{$post->{images}},[$src,".$1"];
			}
			else {
				push @{$post->{images}},[$src,".jpg"];
			}
		}
		if((!$post->{info}) and m/<a[^>]*href="\/(\d+\/[^\?"]+)[^"]*"[^>]*title="([^"]+)"/) {
			#$post->{info} = "$2_$1_" . $post->{text};
			$post->{info} = "$2_$1";#_" . $post->{text};
			$post->{info} =~ s/[\/\?]/_/g;
			$post->{info} =~ s/[-\s:]//g;
		}
		push @posts,$post;
	}
	foreach(@posts) {
		my $idx = 0;
		my @images = @{$_->{images}};
		my $count = @{$_->{images}};
		my $title = $_->{info};
		my $html = $_->{text};
		if($count == 1) {
			push @data, $images[0]->[0] . "\t" . $title . $images[0]->[1];
#			$html .= "<img src=\"" . $title . $images[0]->[1] . "\"><br/>";
		}
		else {
			foreach(@images) {
				$idx++;
				push @data,$_->[0] . "\t" . $title ."_" .strnum($idx,3) .   $_->[1];
#				$html .= "<img src=\"" . $title ."_" . strnum($idx,3) .  $_->[1] . "\"><br/>";
			}
		}
		push @data,new_html_data($html,$title,$url);
	}
	return (
		count=>scalar(@data),
		data=>\@data,
		url=>$url,
	);
}

sub process_pages {
	my($url,$rule,$level) = @_;
	my $uid;
	if($url =~ m/\/u\/(\d+)/) {
		$uid = $1;
	}
	elsif($url =~ m/\/p\/100505(\d+)/) {
		$uid = $1;
	}
	else {
		return (
			"error"=>"Invalid url.",
		);
	}
	my $lastpage = build_page_url($uid,10000);
	print STDERR "Retriving past-last page...\n";
	my $lasthtml = get_html($lastpage);
	my $maxp = 1;
	while($lasthtml =~ m/&page=(\d+)/g) {
		if($1 > $maxp) {
			$maxp = $1;
		}
	}
	my @pass_data;
	for my $pid(1..$maxp) {
		push @pass_data,build_page_url($uid,$pid);
	}
	return (
		pass_data=>\@pass_data,
		pass_count=>scalar(@pass_data),
	);
}

sub process_weibo {
	my $url = shift;
	my $html = get_html($url,"-v");


	my $user;
	my $nick;
	my $id;

	if($url =~ m/weibo\.com\/([^\/\?]+)[^\/]*$/) {
		$user = $1;
	}
	if($html =~ m/\$CONFIG\['oid'\]='(\d+)'/) {
		$id = $1;
	}
	if($html =~ m/\$CONFIG\['onick'\]='([^']+)'/) {
		$nick = $1;
	}
	return (
		pass_data => [ $id ? "http://weibo.com/u/$id" : $url ],
		title=> $user || $nick || $id || "",
	);
}

sub apply_rule {
	my $url = shift;
	my $rule = shift;
	my $level = $rule->{level} || 0;
	if(!$level) {
		if($url =~ m/&page=(\d+)/) {
			return process_page($url,$level,$rule,$1);
		}
		else {
			return process_page($url,$level,$rule,1);
		}
	}
	elsif($level == 1) {
		return process_pages($url,$level,$rule);
	}
	elsif($level == 2) {
		return process_weibo($url,$level,$rule);
	}
}

# vim:filetype=perl
