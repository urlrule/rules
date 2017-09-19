#!/usr/bin/perl -w
#miaopai.com
#Mon Jan  5 00:22:37 2015
use strict;
no warnings 'redefine';

#http://120.198.232.217/wscdn.miaopai.com/stream/GMFLiWlV3gnYy4wGItQoiA__.mp4?wsiphost=local


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
	$title =~ s/[\r\n\/\?:\*\>\<\|]+/ /g;
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

sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
    my @html = split(/\n/,$html);
	my %info;
	my %now;
	(undef,undef,undef,$now{day},$now{month},$now{year}) = localtime(time);
	$now{year} += 1900;
#	$info{year} = "";
	$now{month} += 1;
#	$now{month} = "0" . $info{month} if($info{month} < 10);
#	$now{day} = "0" . $info{day} if($info{day} < 10);
	$info{desc} = "";
	foreach(@html) {
		if(m/<meta property="og:([^"]+)"[^>]+content="([^"]+)"/) {
			$info{$1} = $2;
		}
		elsif(m/<h2><b>前天/) {
			$info{year} = $now{year};
			$info{day} = $now{day} - 2;
			$info{month} = $now{month};
		}
		elsif(m/<h2><b>昨天/) {
			$info{year} = $now{year};
			$info{day} = $now{day} -1;
			$info{month} = $now{month};
		}
		elsif(m/^\s*<span>(\d+)-(\d+)-(\d+)<\/span>/) {
			$info{year} = $1;
			$info{month} = $2;#($1 < 10 ? "0$1" : $1);
			$info{day} = $3;#($2 < 10 ? "0$2" : $2);
		}
		elsif(m/^\s*<span>(\d+)-(\d+)/) {
			$info{month} = $1;#($1 < 10 ? "0$1" : $1);
			$info{day} = $2;#($2 < 10 ? "0$2" : $2);
		}
		#elsif(m/<h2><b>(\d+)-(\d+)\s+(\d+):(\d+)/) {
		#	$info{month} = $1;
		#	$info{day} = $2;
		#	$info{hour} = $3;
		#	$info{minute} = $4;
		#}
		elsif((!$info{desc}) and m/^\s*<p>\s*(.+?)\s*<\/p>/) {
			$info{desc} = $1;
			$info{desc} =~ s/<[^>]+>//g;
			$info{desc} =~ s/\s+$//;
			$info{maxlen} = 60;
		}
		elsif((!$info{image}) and m/src="([^"]+miaopai\.com\/stream\/[^"]+\.jpg)"/) {
			$info{image} = $1;
		}
		elsif((!$info{scid}) and m/^\s*"scid":"([^"]+)"/) {
			$info{scid} = $1;
		}
		elsif((!$info{image}) and m/^\s*"poster":"([^"]+)"/) {
			$info{image} = $1;
		}
		elsif((!$info{video}) and m/^\s*"videoSrc":"([^"]+)"/) {
			$info{video} = $1;
		}
		elsif((!$info{title}) and m/^\s*"title":"([^"]+)"/) {
			$info{title} = $1;
		}
		elsif(m/<a class="one_title[^>]+title="([^"]+)"/) {
			$info{desc} = $1;
		}
		elsif(m/<div class="footer">/) {
			last;
		}
	}
	foreach(qw/year month day/) {
		$info{$_} = int($info{$_}) if($info{$_});
	}
	if(!$info{image}) {
		return (error=>"Error parsing $url");
	}
	$info{imageext} = 'jpg';
	$info{videoext} = 'mp4';
	if($info{video}) {
		if($info{video} =~ m/\.([^\.]+)$/) {
			$info{videoext} = $1;
			$info{videoext} =~ s/[\?#].*$//;
		}
	}
	else{ 
		return (error=>"Error parsing $url");
	}
	$info{month} ||= $now{month}; 
#	$info{day} ||= $now{day};
	if($info{day} and $info{day} < 1) {
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
	$info{day} = "0" . $info{day} if($info{day} and length($info{day}) < 2);
	if($info{desc}) {
		$info{desc} = extract_title($utf8->decode($info{desc}));
	}
	if(!$info{day}) {
		$info{year} = '';
		$info{month} = '';
		$info{day} = '';
	}
	$info{id} =~ s/_+// if($info{id});
	my $basename = $info{year} . $info{month} . $info{day} . "_" . $info{id};
	$basename .= "_" . $info{desc} if($info{desc});
	$basename =~ s/^_+//;
	push @data,$info{video} . "\t" . $basename ."." . $info{videoext}; 
	push @data,$info{image} . "\t" . $basename . "." . $info{imageext}; 
    return (
		info=>\%info,
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$title,
    );
}


1;

__END__

#       vim:filetype=perl
