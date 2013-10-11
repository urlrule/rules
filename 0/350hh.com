#!/usr/bin/perl -w
#http://www.88dy.tv/view/index359.html
#Mon Oct  7 07:01:54 2013
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
use Encode qw/find_encoding/;
my $gbk = find_encoding('gbk');
my $utf8 = find_encoding('utf8');

sub html2txt {
	my $_ = $_[0];
	if(m/<br\s*\/>[　\s]+<br\s*\/>/) {
		s/<br\s*\/>[　\s]+<br\s*\/>/\r\n/g;
		s/<br\s*\/>//g;
	}
	elsif(m/<br\s*>[　\s]+<br\s*>/) {
		s/<br\s*>[　\s]+<br\s*>/\r\n/g;
		s/<br\s*>//g;
	}
	else {
		s/<br\s*\/>/\r\n/g;
	}
	return $_;
}

sub apply_html_rule {
	my($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my @html = split(/\n/,$utf8->encode($gbk->decode($html)));
	my $title;
	my $content="";
	my $f_text;
	my $ext='.txt';
	my @data=();
	foreach(@html) {
		chomp;
		if(m/<title>([^<]+?)\s*-\s*</) {
			$title = $1;
		}
		elsif(m/div class="(novel|pic)Content">(.*)$/) {
			$f_text=1;
			$content=$2;
		}
		elsif(m/div class=temp22>(.*)$/) {
			$f_text=1;
			$content=$1;
		}
		elsif($f_text) {
			if(m/^(.*)<\/div>/) {
				$content .= $1;
				$f_text=0;
				last;
			}
			else {
				$content .= $_;
			}
		}
	}
	if($content =~ m/<img|thunder|<div|href=/) {
		$ext=".html";
		$content = '
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>' . $title . '</title>
</head><body>' .
$content . 
'</body></html>';
	}
	else {
		$content = $title ."\n" . html2txt($content);
	}
	if(!$title) {
		return (error=>"Invalid page.");
	}
	my $tmpfile=`mktemp -t --suffix=$ext tmp.XXXXXXXX`;
	chomp($tmpfile);
	open FO,'>',$tmpfile or return (error=>$!);
	print FO "$content\n";
	close FO;
	push @data,"file://$tmpfile\t$title$ext";
	my $img=0;
	while($content =~ m/<img[^<]*src="([^"]+)(\.[^"\.]+)"/g) {
		$img++;
		push @data,"$1$2\t$title$img$2";
	}
	my $count=scalar(@data);
	return (
		data_count=>$count,
		data=>\@data,
#		title=>($count>3 ? $title : undef),
	);
}

sub apply_rule {
    my ($url,$rule) = @_;
	my $site;
	my $id;
	if($url =~ m/\/article\//){
		return apply_html_rule($url,$rule);
	}
	elsif($url =~ m/^(.+)\/[^\/]+\/[^\/]*?(\d+)\.html.*$/) {
		$site = $1;
		$id = $2;
	}
	else {
		return (
			'error'=>"Invalid url: $url",
		)
	}
	my $html = get_url($url,'-v');
	if(!$html) {
		return (
			'error'=>"Failed restriving $url",
		);
	}
	my $cover;
	if($html =~ m/<img src="([^"]+)" title="/) {
		$cover = "$site/$1";
	}
	elsif($html =~ m/class="cover"><img src="([^"]+)"/) {
		$cover = "$site/$1";
	}
	my $url2 = "$site/player/$id.html";
	if($html =~ m/<a[^>]*href=['"]([^'"]*\/player\/[^'"]+)/) {
		$url2 = $1;
		if($url2 !~ m/^http:\/\//) {
			$url2 = "$site$url2";
		}
	}
	$html = get_url($url2,'-v');
	if(!$html) {
		return (
			'error'=>"Failed restriving $url2",
		);
	}
    my $title = undef;
    my @data;
    my @pass_data;
	my $url3;
    my @html = split(/\n/,$utf8->encode($gbk->decode($html)));
	foreach(@html) {
		if(m/src="(\/playdata\/[^"]+)/) {
			$url3 = "$site$1";
			last;
		}
		elsif(!$title) {
			if(m/<title>正在播放\s*([^<]+?)\s*<\/title/){
				$title = $1;
			}
			elsif(m/<title>([^<]+?)在线观看/) {
				$title = $1;
			}
		}
	}
	$html = get_url($url3,'-v');
	if(!$html) {
		return (
			'error'=>"Failed retriving $url3",
		)
	}
	$html =~ s/\\u(....)/\\x{$1}/g;
	$html = $utf8->encode($gbk->decode($html));
	$html =~ s/%7C/|/g;
	my @qvod;
	while($html =~ m/'([^']+)\$([^']+)\$qvod'/g) {
		my $name = $utf8->encode(eval("\"\" . \"$1\""));
		my $qvod = $utf8->encode(eval("\"\" . \"$2\""));
		my $ext = '';
		if($qvod =~ m/(\.[^\.]+?)\|?$/) {
			$ext = $1;
		}
		push @qvod,[$qvod,"_$name",$ext];		
	}
	my $count = @qvod;
	if($count > 1) {
		foreach(@qvod) {
			my $url = $_->[0];
			if($title) {
				$url =~ s/^(qvod:\/\/.+\|)[^\|]+\|$/$1${title}$_->[1]$_->[2]|/;
				push @data,"qvod:$url\t${title}$_->[1]$_->[2]";
			}
			else {
				push @data,"qvod:$url";
			}
		}
	}
	else {
		my $url = $qvod[0]->[0];
		if($title) {
			$url =~ s/^(qvod:\/\/.+\|)[^\|]+\|$/$1${title}$qvod[0]->[2]|/;
			@data = ("qvod:$url\t${title}$qvod[0]->[2]");
		}
		else {
			@data = ("qvod:$url");
		}
	}
	push @data,"$cover\t${title}.jpg" if($cover);
    return (
        count=>scalar(@data),
        data=>\@data,
        pass_count=>0,
#		title=>$title,
    );
}

=cut

1;

__END__

#       vim:filetype=perl
