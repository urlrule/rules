#!/usr/bin/perl -w
#http://www.weishi.com/t/2003061038631146?pgv_ref=weishi.sync.weibo&pgv_uid=6020984
#Sun Mar  8 00:27:33 2015
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
       何旋君君'pass_exp'=>undef,
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
use Encode qw/find_encoding/;
my $utf8 = find_encoding('utf8');

sub extract_title {
	my $title = shift;
	return "" unless($title);
	$title =~ s/^\s+//;
	$title =~ s/<[^.>]+>//g;
	$title =~ s/\/\?\*'"//g;
	$title =~ s/&amp;amp;/&/g;
	$title =~ s/&amp;/&/g;
	$title =~ s/&hellip;/…/g;
	$title =~ s/[\r\n]+/ /g;
#	$title =~ s/\x{1f60f}|\x{1f614}|\x{1f604}//g;
#	$title =~ s/[\P{Print}]+//g;
#	$title =~ s/[^\p{CJK_Unified_Ideographs}\p{ASCII}]//g;
	$title =~ s/[^{\p{Punctuation}\p{CJK_Unified_Ideographs}\p{CJK_SYMBOLS_AND_PUNCTUATION}\p{HALFWIDTH_AND_FULLWIDTH_FORMS}\p{CJK_COMPATIBILITY_FORMS}\p{VERTICAL_FORMS}\p{ASCII}\p{LATIN}\p{CJK_Unified_Ideographs_Extension_A}\p{CJK_Unified_Ideographs_Extension_B}\p{CJK_Unified_Ideographs_Extension_C}\p{CJK_Unified_Ideographs_Extension_D}]//g;
#	$title =~ s/[\p{Block: Emoticons}]//g;
	#print STDERR "\n\n$title=>\n", length($title),"\n\n";
	my $maxlen = 70;
	if(length($title) > $maxlen) {
		$title = substr($title,0,$maxlen);
	}	
	return $utf8->encode($title);
}


#http://www.weishi.com/t/2003061038631146?pgv_ref=weishi.sync.weibo&pgv_uid=6020984
sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
	my %info;
	my %now;
	(undef,undef,undef,$now{day},$now{month},$now{year}) = localtime(time);
	$now{year} += 1900;
#	$info{year} = "";
	$now{month} += 1;
#	$now{month} = "0" . $info{month} if($info{month} < 10);
#	$now{day} = "0" . $info{day} if($info{day} < 10);

	$info{minute} = '';
	$info{hour} = '';
	
    my @html = split(/\n/,$html);

	my $flag = '';

	foreach(@html) {
		if((!$info{uid}) and m/id="username" href="\/u\/([^\/?#&]+)[^>]+>([^<]+)<\/a/) {
			$info{uid} = $1;
			$info{uname} = $2;
		}

		elsif((!$info{datestr}) and m/class="[^"]*time[^"]*"[^>]*>([^\s]+)\s+(\d\d):(\d\d)<\/span/) {
			$info{datestr} = $1;
			$info{hour} = $2;
			$info{minute} = $3;
			$info{datestr} =~ s/^\s*(.+)\s*$/$1/;
			#print STDERR "DATE:$info{datestr}\n";
			if($info{datestr} eq '前天') {
				$info{year} = $now{year};
				$info{day} = $now{day} - 2;
				$info{month} = $now{month};
			}
			elsif($info{datestr} eq '昨天') {
				$info{year} = $now{year};
				$info{day} = $now{day} -1;
				$info{month} = $now{month};
			}
			elsif($info{datestr}  =~ m/(\d+)-(\d+)-(\d+)/) {
				$info{year} = $1;
				$info{month} = $2;#($1 < 10 ? "0$1" : $1);
				$info{day} = $3;#($2 < 10 ? "0$2" : $2);
			}
			elsif($info{datestr} =~ m/(\d+)-(\d+)/) {
				$info{month} = $1;#($1 < 10 ? "0$1" : $1);
				$info{day} = $2;#($2 < 10 ? "0$2" : $2);
			}
			elsif($info{datestr} =~ m/(\d+)月(\d+)日/) {
				$info{month} = $1;
				$info{day} = $2;
			}
			elsif($info{datestr} =~ m/(\d+)年(\d+)月(\d+)日/) {
				$info{year} = $1 > 2000 ? $1 : (2000+$1);
				$info{month} = $2;
				$info{day} = $3;
			}
		}
		elsif((!$info{message}) and m/<div id="message" class="msgCnt">/) {
			$flag = 'message';
			$info{message} = 1;
			next;
		}
		elsif(m/<div class="pubInfo/) {
			$flag = '';
			next;
		}
		elsif($flag eq 'message') {
			if($info{desc}) {
				$info{desc} = $info{desc} . $_;
			}
			else {
				$info{desc} = $_;
			}
		}
		elsif(m/(\w+)\s*:\s*'([^\']+)'/) {
			$info{$1} = $2;
		}
	}
	if(!$info{vid}) {
		return (
			info=>\%info,
			error=>'No video found on page',
		);
	}

	my $vurl = "http://wsi.weishi.com/weishi/video/downloadVideo.php?v=p" . 
		"&vid=$info{vid}&play=2&device=2" . 
		"&id=$info{msgid}";
	push @{$info{video}},$vurl;

	#my $vhtml = get_url($vurl,'-v');
	#while($vhtml =~ m/"(http:[^"]+)"/g) {
	#	my $video = $1;
	#	$video =~ s/\\//g;
	#	$info{video} = [] unless($info{video});
	#	push @{$info{video}},$video;
	#}
	if(!$info{video}) {
		return (
			info=>\%info,
			error=>'Error parse video info',
		);
	}
	foreach(qw/year month day/) {
		$info{$_} = int($info{$_}) if($info{$_});
	}
	$info{year} += 2000 if($info{year} and $info{year} < 2000);
	$info{month} ||= $now{month}; 
	$info{day} ||= $now{day};
	if($info{day} < 1) {
		$info{month} -=1;
		$info{day} = 30;
	}
	if(!$info{year}) {
		$info{year} = $now{year};
		if($info{month} > $now{month}) {
			$info{year} -= 1;
		}
		elsif($info{month} == $now{month}) {
			$info{year} -= 1 if($info{day} > $now{day});
		}
	}
	if($info{month} < 1) {
		$info{month} = 12;
		$info{year} -= 1;
	}

	$info{month} = "0" . $info{month} if(length($info{month}) < 2);
	$info{day} = "0" . $info{day} if(length($info{day}) < 2);
	$info{videoext} = "mp4";
	$info{imageext} = "jpg";
	if($info{desc}) {
		$info{desc} =~ s/<[^>]+>//g;
		$info{desc} =~ s/\s+$//;
		$info{desc} =~ s/\s{2,}/ /g;
		$info{desc} = extract_title($utf8->decode($info{desc}));
	}
	else {
		$info{desc} = $info{msgid};
	}

	my $basename = $info{year} . $info{month} . $info{day} . $info{hour} . $info{minute};# . "_" . $info{msgid};
	$basename .= "_" . $info{desc} if($info{desc});
	foreach(@{$info{video}}) {
		push @data,$_  . "\t" . $basename ."." . $info{videoext}; 
	}
	push @data,"http://ugc.qpic.cn/weishi_pic/0/$info{vid}_1/480" .
					"\t" . $basename . "." . $info{imageext}; 
    return (
		info=>\%info,
        count=>scalar(@data),
        data=>\@data,
		#download=>\@pass_data,
        base=>$url,
    );
}


1;

__END__

#       vim:filetype=perl
