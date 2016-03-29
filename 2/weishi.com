#!/usr/bin/perl -w

#DOMAIN : weishi.com
#AUTHOR : eotect <eotect@myplace>
#CREATED: 2015-03-08 01:40
#UPDATED: 2015-03-08 01:40

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
       'pass_exp'=>undef,
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
use JSON;
use Encode qw/find_encoding/;
my $utf8 = find_encoding('utf8');
sub decode_json {
	my $json = eval { &JSON::decode_json($_[0]); };
	if($@) {
		print STDERR "Error deocding JSON text:$@\n";
		$@ = undef;
		return {};
	}
	else {
		return $json;
	}
}

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
#http://wsi.weishi.com/weishi/t/other.php?v=p&g_tk=&r=1425749924564&callback=jQuery110205775372174111502_1425749924539&pageflag=0&reqnum=5&uid=6020984&_=1425749924540

#http://wsi.weishi.com/weishi/t/other.php?v=p&g_tk&r=1425749850414&callback=jQuery1102032652092672786626_1425749451844&pageflag=2&reqnum=5&uid=6020984&lastid=2000048101735623&pagetime=1412780474&_=1425749451914

sub apply_rule {
    my ($url,$rule) = @_;
	
	my $id;
	my $page;
	if($url =~ m{weishi\.com/t/}) {
		return (
			count=>0,
			pass_count=>1,
			pass_data=>[$url],
		);
	}
	elsif($url =~ m/\/u\/([^\/#&?]+)/) {
		$id = $1;
		$page = 0;
	}
	elsif($url =~ m/uid=([^&=?]+)/) {
		$id = $1;
		if($url =~ m/pageflag=(\d+)/) {
			$page = $1;
		}
	}
	
	
	my $rurl;
	my $r1 = time()* 1000 + 512;
	my $r2 = $r1 + 1;
	my $r3 = $r2 + 2;
	my $r4 = $r3 + 3;
	if($page) {
		$rurl = $url;
	}
	else {
		$rurl = "http://wsi.weishi.com/weishi/t/other.php?v=p&g_tk=&r=$r1&callback=jQuery110205775372174111502_$r2&pageflag=0&reqnum=5&uid=$id&_=$r3";
	}

	my $html = get_url($rurl,'-v','--referer',"http://www.weishi.com/u/$id");
	$html =~ s/^[^\(]+\(//;
	$html =~ s/\);?$//;
	if(!$html) {
		return (
			error=>'Failed retriving url',
		);
	}
	#print STDERR $html,"\n";
	my $json = decode_json($html);
	print STDERR $json->{msg},"\n";
    my $title;
	my $lastid;
	my $pagetime;
	my @pass_data;
	my $uname;
	my $info = $json->{data};
	
	if($info && $info->{info}) {
		my @videos = @{$info->{info}};
		if($info->{user}) {
			foreach (keys %{$info->{user}}) {
				$title = $info->{user}->{$_};
				$uname = $_;
			}
		}
		foreach my $v (@videos) {
			push @pass_data,"http://www.weishi.com/t/$v->{id}";
			$lastid = $v->{id};;
			$pagetime = $v->{timestamp};
		}
		if($info->{hasNext}) {
			push @pass_data,"http://wsi.weishi.com/weishi/t/other.php?v=p&g_tk&r=$r1&callback=jQuery1102032652092672786626_$r2" .
			"&pageflag=2" . # ($page+1) . 
			"&reqnum=5&uid=$id" .
			"&lastid=$lastid" . 
			"&pagetime=$pagetime" . # . $r3 .
			"&_=$r4";
		}
	}
    return (
		info=>$info,
        count=>0,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>($page ? '' :  $title),
		level=>1,
		id=>$title,
		uname=>$uname,
    );

}

=cut

1;

__END__

#       vim:filetype=perl



