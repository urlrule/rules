#!/usr/bin/perl -w
package MyPlace::URLRule::Rule::common_weibo_com;
use strict;
use utf8;
use MyPlace::WWW::Utils qw/get_url get_html strnum new_html_data expand_url html2text/;
use MyPlace::Weibo qw/extract_post_title m_get_mblog m_get_user/;
use base 'MyPlace::URLRule::Rule';

my $CONFIG_PID = '100505';

my %OPTS;

sub pack_url {
	if($OPTS{TYPE}) {
		return "http://" . $OPTS{TYPE} . ".weibo.com/" . join("",@_);
	}
	else {
		return "http://weibo.com/" . join("",@_);
	}
}

sub unpack_url {
	my $url = shift;
	return unless($url);
	if($OPTS{TYPE}) {
		$url =~ s{http://$OPTS{TYPE}\.}{http://};
	}
	return $url;
}

sub build_page_url {
	my $uid = shift;
	my $pid = shift;
	my $max_id = shift;
	my $end_id = shift;
	my $bar = shift(@_) || 0;
	my $ppid = $pid  || 1;
	return &pack_url("p/aj/mblog/mbloglist") .
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
sub extract_post {
	my $post = {};
	local $_ = shift;
	$_ =~ s/.*pl\.content\.weiboDetail\.index/({"ns":"pl.content.weiboDetail.index/m;
	$_ =~ s/\\(["\/]+)/$1/g;
	$_ =~ s/\s*\\+[ntr]+\s*//g;
	$_ =~ s/\s*\\+[ntr]+\s*//g;
	$_ =~ s/src="([^"]+(?:sina|weibo|sinaimg)\.(?:com|cn)[^"]*)\/(?:orj\d\d\d|thumb\d+|sq\d\d\d|mw\d\d\d\d|thumbnail|square|bmiddle|mw\d\d\d)\/([^"]+)"/src="$1\/large\/$2"/sg;
	my $text = $_;
	$text =~ s/[\n\r]/\\n/sg;
	if($text =~ m/\\u/) {
		$text =~ s/(["@])/\\$1/sg;
		$text =~ s/\\u(....)/\\x{$1}/sg;
		$text = (eval("\"\" . \"$text\""));
	}
#		if(length($text) > 20) {
#			$text =~ s/^\s*([^，。\.,]+).+$/$1/;
#			$text = substr($text,0,20);
#		}
	$post->{images}=[];
	$post->{links} = [];
	if(m/mid="([^"]+)"/) {
		$post->{mid}=$1;
	}
	if(m/feedtype="([^"]+)"/) {
		$post->{feedtype} = $1;
	}
	if((!$post->{info}) and m/<a[^>]*href="\/\d+\/([^\?"]+)[^"]*"[^>]*title="([^"]+)"/) {
		#$post->{info} = "$2_$1_" . $post->{text};
		$post->{info} = "$2_$1";#_" . $post->{text};
		$post->{info} =~ s/[\/\?]/_/g;
		$post->{info} =~ s/[-\s:]//g;
		if($post->{mid}) {
			$post->{info} =~ s/^(\d+)_/${1}_$post->{mid}_/;
		}
	}
	$text =~ s/.*?<div class="WB_face W_fl">//;
	$text =~ s/<div class="WB_like".*//;
	$post->{html}=$text;
	$post->{content} = $text;
	$post->{content} =~ s/.*?<div class="WB_text[^>]+>//;
	$post->{content} =~ s/<[^>]*>//g;
	$post->{content} = html2text($post->{content});

	foreach my $line (split(/[\r\n]/,$text)) {
		while($line =~ m/<img[^>]*src\s*=\s*(['"])([^>]+?)\1/sg) {
			my $src = $2;
			#next unless($src =~ m/large|original/);
			next if($src =~ m/\/style\/images\/|sinajs|http:\/\/tp\d+\.sinaimg\.cn|http:\/\/tc\.sinaimg/);
			next if($src =~ m/beacon\.sina\.|tva[^\.]+\.sinaimg\.|weibo\.com\/a\/vpaint|dslb\.cdn\./);
			$src =~ s/^:?\/\//http:\/\//;
			if($src =~ m/\.([^\.\/]+)$/) {
				push @{$post->{images}},[$src,".$1"];
			}
			else {
				push @{$post->{images}},[$src,".jpg"];
			}
		}
		while($line =~ m/href="(http:\/\/t\.cn[^"]+)/g) {
			my $loc = expand_url($1);
			if($loc =~ m/mob\.com/) {
				$loc = expand_url($loc);
			}
			if($loc =~ m/url\.cn/) {
				$loc = expand_url($loc);
			}
			if($loc =~ m/weibo\.com/) {
				if($loc =~ m/weibo\.com\/tv\/v\/.*?fid=([^&]+)/) {
					$loc = 'http://video.weibo.com/show?fid=' . $1;
				}
				if($loc =~ m/video\.weibo\.com/) {
					$loc = "$loc&title=" . $post->{info} if($post->{info});
					push @{$post->{data}},$loc;
				}
				next;
			}
			$loc = $loc . "\t" . $post->{info} if($post->{info});
			push @{$post->{links}},$loc;
		}
	}
	return $post;
}

sub process_post {
	my($url,$level,$rule) = @_;	
	my $content = get_url($url,'-v');
	my @data;
	local $_ = extract_post($content);
		my $idx = 0;
		my @images = @{$_->{images}} if($_->{images});
		my $count = @{$_->{images}} if($_->{images});;
		my $title = $_->{info};
		my $html = $_->{html};
		my $with_images = 1;
		my @outer_links;
		if($_->{content}) {
			$_->{title} = extract_post_title($_->{content},1);
			$title = $title . "_" . $_->{title} if($_->{title});
		}
		if($OPTS{HTML}) {
			push @data,$_->{html};
			$with_images = 0;
		}
		elsif($OPTS{LINKS}) {
			if($_->{links}) {
				push @data,(@{$_->{links}});
				delete $_->{links};
			}
			$with_images = 1;
		}
		if(!$with_images) {
		}
		elsif($count>0) {
			push @data, $images[0]->[0] . "\t" . $title . $images[0]->[1];
			my $idx = 1;
			while($idx<$count) {
				my $img = $images[$idx];
				$idx++;
				push @data,$img->[0] . "\t" . $title ."_" .strnum($idx,3) .   $img->[1];
			}
		}
		else {
			print STDERR "No images found for post <$title>\n";
		}
		if($_->{links}) {
			foreach my $loc(@{$_->{links}}) {
				push @outer_links,$loc;
			}
		}
		delete $_->{html};
		#push @data,new_html_data($html,$title,$url);

	my %r = (
		info=>$_,
		count=>scalar(@data),
		data=>\@data,
		url=>$url,
	);
	$r{outer_links} = \@outer_links if(@outer_links);
	if(@outer_links) {
		#push @{$r{data}},grep(/(?:miaopai.com|meipai.com|weipai.cn|p\.weibo.com|video\.weibo\.com)/,@outer_links);
		push @{$r{data}},grep(/(?:huajiao\.com|yizhibo\.com|weipai\.cn|p\.weibo.com|video\.weibo\.com|v\.xiaokaxiu\.com\/v\/|xiaoying\.tv\/v\/)/,@outer_links);
	}
	return %r;

}

sub process_page {
	my($url,$level,$rule,$page,$maxretry) = @_;
	print STDERR "Retriving page $page...\n";
	my $html = get_url(&unpack_url($url));#,"--verbose");
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
	my @pass_data;
	my @outer_links;
	#print STDERR $html;
	while($html =~ m/(<div[^>]*tbinfo=[^>]*>.+?)<div node-type="feed_list_repeat"/sg) {
		push @blocks,$1;
	}
	my $load_more=undef;
	if($html =~ m/<div[^>]*node-type="lazyload"/) {
		$load_more=1;
	}
	foreach(@blocks) {
		my $post = extract_post($_);
		if($post) {
			push @posts,$post;
			push @data,@{$post->{data}} if($post->{data});
		}
	}
	foreach(@posts) {
		my $idx = 0;
		my @images = @{$_->{images}};
		my $count = @{$_->{images}};
		my $title = $_->{info};
		my $html = $_->{html};
		my $with_images = 1;

		if($OPTS{WEIPAI}) {
			my @shots;
			my @links;
			foreach(@images) {
				my $url = $_->[0];
				if($url =~ m/http:\/\/(?:aliv\.|v\.)weipai\.cn|http:\/\/oldvideo\.qiniudn\.com/) {
					push @shots,$url;
				}
				else {
					push @data,$_->[0] . "\t" . $title ."_" .strnum($idx,3) .   $_->[1];
				}
			}
			if($html =~ m/weipai\.cn/) {
				while($html =~ m/href="(http:\/\/t\.cn[^"]+)/g) {
					my $loc = expand_url($1);
					if($loc =~ m/mob\.com/) {
						$loc = expand_url($loc);
					}
					if($loc =~ m/url\.cn/) {
						$loc = expand_url($loc);
					}
					if($loc =~ m/weipai\.cn\/video\/[^\/]+$/) {
						push @links,$loc;
					}
					else {
						push @data,$loc;
					}
				}
			}
			if(@links) {
				push @data,@links;
			}
			elsif(@shots) {
				push @data,@shots;
			}
			$with_images = 0;
		}
		elsif($OPTS{HTML}) {
			push @data,$_->{html};
			$with_images = 0;
		}
		elsif($OPTS{LINKS}) {
			if($_->{links}) {
				push @data,(@{$_->{links}});
				delete $_->{links};
			}
			$with_images = 1;
		}
		if(!$with_images) {
		}
		elsif($count>0) {
			push @data, $images[0]->[0] . "\t" . $title . $images[0]->[1];
			my $idx = 1;
			while($idx<$count) {
				my $img = $images[$idx];
				$idx++;
				push @data,$img->[0] . "\t" . $title ."_" .strnum($idx,3) .   $img->[1];
			}
		}
		else {
			print STDERR "No images found for post <$title>\n";
		}
		if($_->{links}) {
			foreach my $loc(@{$_->{links}}) {
				push @outer_links,$loc;
			}
		}
		delete $_->{html};
		#push @data,new_html_data($html,$title,$url);
	}
	
	my $max_id;
	my $end_id;
	my $uid = extract_uid($url);
	my %r = (
		info=>\@posts,
		count=>scalar(@data),
		data=>\@data,
		url=>$url,
		pass_data=>\@pass_data,
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
			$max_id = $posts[$#posts]->{mid} if(@posts);
			push @pass_data,build_page_url($uid,$page,$max_id,$end_id,1);
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
			$max_id = $posts[$#posts]->{mid} if(@posts);
			push @pass_data,build_page_url($uid,$page,$max_id,$end_id,0);
		}
	}
	$r{pass_data} = \@pass_data;
	$r{pass_count} = scalar(@pass_data);
	$r{samelevel} = 1;
	$r{outer_links} = \@outer_links if(@outer_links);
	if(@outer_links) {
		#push @{$r{data}},grep(/(?:miaopai.com|meipai.com|weipai.cn|p\.weibo.com|video\.weibo\.com)/,@outer_links);
		push @{$r{data}},grep(/(?:huajiao\.com|yizhibo\.com|weipai.cn|p\.weibo.com|video\.weibo\.com|v\.xiaokaxiu\.com\/v\/|xiaoying\.tv\/v\/)/,@outer_links);
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
	my $lastpage = build_page_url($uid,400);
	print STDERR "Retriving past-last page...\n";
	my $lasthtml = get_html(&unpack_url($lastpage));
	if($lasthtml =~ m/<div class="page_error">(.+?)<\/div/s) {
		my $err = $1;
		$err =~ s/<[^>]+>//sg;
		$err =~ s/[\s\t\r\n]+//sg;
		return (
			error=>$err,
		);
	}
	my $maxp = 1;
	if($lasthtml !~ m/<title>Sina Visitor System<\/title>/) {
		while($lasthtml =~ m/(?:&|&amp;)page=(\d+)/g) {
			next if($1 eq 400);
			if($1 > $maxp) {
				$maxp = $1;
			}
		}
	}
	my @pass_data;
	for my $pid(1..$maxp) {
		push @pass_data,&pack_url("p/${CONFIG_PID}$uid/home?is_search=0&visible=0&is_tag=0&profile_ftype=1&page=$pid#feedtop");
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
	elsif($url =~ m/weibo\.com\/u\/(\d+)/) {
		$id = $1;
	}
	elsif($url =~ m/weibo\.com\/([^\/\?]+)[^\/]*$/) {
		$user = $1;
	}
	my $html = get_html(&unpack_url($url),"-v");
	if($html =~ m/location\.replace\("([^"]+)/) {
		print STDERR "Redirect to : $1\n";
		$html = get_html($1);
	}
	if($html =~ m/<div class="page_error">(.+?)<\/div/s) {
		my $err = $1;
		$err =~ s/<[^>]+>//sg;
		$err =~ s/[\s\t\r\n]+//sg;
		return (
			error=>$err,
		);
	}
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
		pass_data => [ $id ? &pack_url("u/$id") : $url ],
		title=> $user || $id || $nick || "",
		info=>{
			oid=>$id,
			ouser=>$user,
			onick=>$nick,
			pid=>$CONFIG_PID
		},
		uid=>$id,
		profile=> ($id ? 'u/' . $id : $user),
		host=>'weibo.com',
		uname=>$nick,
	);
}

sub apply_rule {
	my $self = shift;
	my $url = shift;
	my $rule = shift;
	my $level = $rule->{level} || 0;
	if($url =~ m/https?:\/\/([^\.]+)\.weibo\.com/) {
		$OPTS{TYPE} = $1;
		$OPTS{uc($1)} = 1;
	}
	if($rule->{level_desc} and 'info' eq "$rule->{level_desc}") {
		return process_weibo($url,$level,$rule);
	}
	if(!$level) {
		if($url =~ m/\/tv\/v\/.*pid=([^&]+)/) {
			return (
				data=>["http://video.weibo.com/show?fid=$1"],
			);
		}
		elsif($url =~ m/weibo\.com\/p\/([^\/]+)$/) {
			my $pid = $1;
			my $html = get_url($url,'-v');
			if($html =~ m/file=([^"&]+\.m3u8[^"&]*)/) {
				return (
					data=>['http://video.weibo.com/p/' . $pid],
				);
			}
		}
		elsif($url =~ m/weibo\.com\/\d+\/([^\/]+)$/) {
			return m_get_mblog("https://m.weibo.cn/detail/$1");
		}
		elsif($url =~ m/weibo\.com\/status\/[^\/]+$/) {
			return process_post($url,$level,$rule);
		}
		elsif($url =~ m/m\.weibo\.cn\/detail\/.+/) {
			return m_get_mblog($url);
		}
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

return new MyPlace::URLRule::Rule::common_weibo_com;

# vim:filetype=perl
