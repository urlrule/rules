#!/usr/bin/perl -w
use strict;
use utf8;

use MyPlace::URLRule::Utils qw/get_url get_html strnum new_html_data/;

my $CONFIG_PID = '100505';


sub build_page_url {
	my $uid = shift;
	my $pid = shift;
	my $max_id = shift;
	my $end_id = shift;
	my $bar = shift(@_) || 0;
	my $ppid = $pid  || 1;
	return "http://weibo.com/p/aj/mblog/mbloglist" .
			"?domain=${CONFIG_PID}" . 
			($ppid ? "&pre_page=$ppid" : "") .
			"&page=$pid" .
			($max_id ? "&max_id=$max_id" : "") .
			($end_id ? "&end_id=$end_id" : "") .
			"&count=15" .
			"&pagebar=$bar" . 
			"&pl_name=Pl_Official_LeftProfileFeed__13" .
			"&id=${CONFIG_PID}$uid" .
			"&script_uri=/p/${CONFIG_PID}$uid/weibo" .
			"&feed_type=0" .
			"&from=page_${CONFIG_PID}" .
			"&mod=TAB" .
			"&__rnd=" . rand(1)*1000000000000;
}

sub extract_uid {
	my $url = shift;
	my $uid;
	if($url =~ m/[\?&]id=(100\d\d\d)(\d+)/) {
		$CONFIG_PID = $1;
		$uid = $2;
	}
	elsif($url =~ m/weibo\.com\/p\/(100\d\d\d)(\d+)/) {
		$CONFIG_PID = $1;
		$uid = $2;
	}
	elsif($url =~ m/weibo\.com\/u\/(\d+)/) {
		$uid = $1;
	}
	return $uid;
}

sub process_page {
	my($url,$level,$rule,$page,$maxretry) = @_;
	print STDERR "Retriving page $page...\n";
	my $html = get_url($url);#,"--verbose");
	$maxretry ||= 0;
#	print STDERR $html,"\n";
	if($html =~ m/<div class="page_error">(.+?)<\/div/s) {
		my $err = $1;
		$err =~ s/<[^>]+>//sg;
		$err =~ s/[\s\t\r\n]+//sg;
		return (
			error=>$err,
		);
	}
	if(length($html) < 1000 and $maxretry>0) {
		print STDERR "Failed. Reloading ...\n";
		sleep 3;
		$maxretry--;
		return process_page($url,$level,$rule,$page,$maxretry);
	}
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
	my $load_more=undef;
	if($html =~ m/<div[^>]*node-type="lazyload"/) {
		$load_more=1;
	}
	foreach(@blocks) {
		my $post = {};
		$_ =~ s/src="([^"]+(?:sina|weibo|sinaimg)\.(?:com|cn)[^"]*)\/(?:thumbnail|square|bmiddle|mw690)\/([^"]+)"/src="$1\/large\/$2"/sg;
		my $text = $_;
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
		$post->{text}=$text;
		$post->{images}=[];
		if(m/mid="([^"]+)"/) {
			$post->{mid}=$1;
		}
		if(m/feedtype="([^"]+)"/) {
			$post->{feedtype} = $1;
		}
		while(m/<img[^>]*src\s*=\s*(['"])([^>]+?)\1/sg) {
			my $src = $2;
			#next unless($src =~ m/large|original/);
			next if($src =~ m/\/style\/images\/|sinajs/);
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

	my $max_id;
	my $end_id;
	my $uid = extract_uid($url);
	my %r = (
		count=>scalar(@data),
		data=>\@data,
		url=>$url,
	);
	if($load_more && $uid) {
		if($url =~ m/[\?&]end_id=(\d+)/) {
			$end_id=$1;
			foreach(@posts) {
				if(!$max_id) {
					$max_id = $_->{mid} unless($_->{feedtype} && ($_->{feedtype} eq "top"));
				}
				else {
					last;
				}
			}
			$max_id = $posts[$#posts]->{mid};
			$r{pass_data} = [build_page_url($uid,$page,$max_id,$end_id,1)];
		}
		else {
			foreach(@posts) {
				if(!$end_id) {
					$end_id = $_->{mid} unless($_->{feedtype} && ($_->{feedtype} eq "top"));
				}
				else {
					last;
				}
			}
			$max_id = $posts[$#posts]->{mid};
			$r{pass_data} = [build_page_url($uid,$page,$max_id,$end_id,0)];
		}
		$r{samelevel} = 1;
	}
	return %r;
}

sub process_pages {
	my($url,$rule,$level) = @_;
	my $uid;
	if($url =~ m/\/u\/(\d+)/) {
		$uid = $1;
	}
	elsif($url =~ m/\/p\/(100\d\d\d)(\d+)/) {
		$CONFIG_PID = $1;
		$uid = $2;
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
		push @pass_data,"http://weibo.com/p/${CONFIG_PID}$uid/home?is_search=0&visible=0&is_tag=0&profile_ftype=1&page=$pid#feedtop";
	}
	return (
		pass_data=>\@pass_data,
		pass_count=>scalar(@pass_data),
	);
}

sub process_weibo {
	my $url = shift;
		my $user;
		my $nick;
		my $id;
	if($url =~ m/weibo\.com\/(\d+)/) {
		$id = $1;
	}
	elsif($url =~ m/weibo\.com\/([^\/\?]+)[^\/]*$/) {
		$user = $1;
	}
	my $html = get_html($url,"-v");
	if($url =~ m/weibo\.com\/([^\/\?]+)[^\/]*$/) {
		$user = $1;
	}
	if($html =~ m/\$CONFIG\['oid'\]='(\d+)'/) {
		$id = $1;
	}
	if($html =~ m/\$CONFIG\['onick'\]='([^']+)'/) {
		$nick = $1;
	}
	if($html =~ m/\$CONFIG\['(?:pid|domain)'\]='(\d+)'/) {
		$CONFIG_PID = $1;
	}
	if($html =~ m/\$CONFIG\['page_id'\]='(\d\d\d\d\d\d)/) {
		$CONFIG_PID = $1;
	}
	return (
		pass_data => [ $id ? "http://weibo.com/u/$id" : $url ],
		title=> $user || $id || $nick || "",
		info=>{
			oid=>$id,
			ouser=>$user,
			onick=>$nick,
			pid=>$CONFIG_PID
		},
	);
}

sub apply_rule {
	my $url = shift;
	my $rule = shift;
	my $level = $rule->{level} || 0;
	if(!$level) {
		my $page = 1;
		if($url =~ m/&page=(\d+)/) {
			$page = $1;
		}
		return process_page($url,$level,$rule,$page,4);
	}
	elsif($level == 1) {
		return process_pages($url,$level,$rule);
	}
	elsif($level == 2) {
		return process_weibo($url,$level,$rule);
	}
}

# vim:filetype=perl
