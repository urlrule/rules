#!/usr/bin/perl -w
#info
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
	my %info;
	my %now;
	
    my @html = split(/\n/,$html);


	foreach(@html) {
		if((!$info{uid}) and m/id="username" href="\/u\/([^\/?#&]+)[^>]+>([^<]+)<\/a/) {
			$info{uid} = $1;
			$info{uname} = $2;
		}
		elsif(m/(\w+)\s*:\s*'([^\']+)'/) {
			$info{$1} = $2;
		}
	}
    return (
		info=>\%info,
        base=>$url,
		uid=>$info{uid},
		uname=>$info{uname},
		profile=>$info{uid},
		host=>'weishi.com',
		url=>"http://www.weishi.com/u/$info{uid}",
    );
}


1;

__END__

#       vim:filetype=perl
