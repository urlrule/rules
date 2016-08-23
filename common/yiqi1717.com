#!/usr/bin/perl -w
#DOMAIN : www.yiqi1717.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2016-08-14 02:41
#UPDATED: 2016-08-14 02:41
#TARGET : http://www.yiqi1717.com/share/live?uid=5511333 :common
#URLRULE: 2.0
package MyPlace::URLRule::Rule::common_www_yiqi1717_com;
use MyPlace::URLRule::Utils qw/get_url/;
use MyPlace::String::Utils qw/strtime/;
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
use Encode qw/find_encoding/;
my $utf8 = find_encoding('utf8');
use utf8;
sub extract_title {
	my $title = shift;
	return unless($title);
	$title = $utf8->decode($title);
	$title =~ s/<[^.>]+>//g;
	$title =~ s/&amp;amp;/&/g;
	$title =~ s/&amp;/&/g;
	$title =~ s/&hellip;/…/g;
	$title =~ s/&[^&]+;//g;
#	$title =~ s/\x{1f60f}|\x{1f614}|\x{1f604}//g;
#	$title =~ s/[\P{Print}]+//g;
#	$title =~ s/[^\p{CJK_Unified_Ideographs}\p{ASCII}]//g;
	$title =~ s/[^{\p{Punctuation}\p{CJK_Unified_Ideographs}\p{CJK_SYMBOLS_AND_PUNCTUATION}\p{HALFWIDTH_AND_FULLWIDTH_FORMS}\p{CJK_COMPATIBILITY_FORMS}\p{VERTICAL_FORMS}\p{ASCII}\p{LATIN}\p{CJK_Unified_Ideographs_Extension_A}\p{CJK_Unified_Ideographs_Extension_B}\p{CJK_Unified_Ideographs_Extension_C}\p{CJK_Unified_Ideographs_Extension_D}]+//g;
	$title =~ s/的直播间$//;
#	$title =~ s/[\p{Block: Emoticons}]//g;
	#print STDERR "\n\n$title=>\n", length($title),"\n\n";
	$title =~ s/[\r\n\/\?'":\*\>\<\| ”]+//g;
	my $maxlen = 70;
	if(length($title) > $maxlen) {
		$title = substr($title,0,$maxlen);
	}	
	$title =~ s/^[\-\_\s\.]+//g;
	$title =~ s/[\-\_\s\.]+$//g;
	$title = $utf8->encode($title);
	return $title;
}

sub process_info {
	my ($url,$level,$rule) = @_;
	my $id;
	if($url =~ m/uid=([^\d+]+)/) {
		$id = $1;
	}
	my $html = get_url($url,'-v');
    my @html = split(/\n/,$html);
	my %info;
	foreach(@html) {
		if((!$info{uid}) and m/uid\s*:\s*'(\d+)'/) {
			$info{uid} = $1;
		}
		elsif((!$info{playlist}) and m/file\s*:\s*'(http[^']+)'/) {
			$info{playlist} = $1;
		}
		elsif((!$info{cover}) and m/image\s*:\s*'(http[^']+)'/) {
			$info{cover} = $1;
		}
		elsif((!$info{uname}) and m/desc\s*:\s*'([^']+)'/) {
			$info{uname} = extract_title($1);
		}
	}
	$info{uname} = $info{uid} unless($info{uname});
	$info{host} = 'yiqi1717.com';
	$info{profile} = $info{uid};
	$info{title} = $info{uname};
	return %info;
}

sub apply_rule {
	my $self = shift;
	my $url = shift;
	my $rule = shift;
	my $level = $rule->{level} || 0;
	my %info = process_info($url,$level,$rule);

	if($rule->{level_desc} and 'info' eq "$rule->{level_desc}") {
		return %info;
	}
	if($info{uid}) {
		my @data = ();
		push @data, $info{cover} . "\t" . "$info{uid}_$info{uname}.jpg";
		if($info{playlist}) {
			push @data, 'http://yiqihdl.8686c.com/pajia/' . "$info{uid}.flv" .
						"\t$info{uid}_$info{uname}.flv";
		}
		return (
			%info,
			data=>\@data,
			count=>scalar(@data),
			title=>$info{uid},
		);
	}
	else {
		return (
			error=>'Failed parsing page',
		);
	}
}

return new MyPlace::URLRule::Rule::common_www_yiqi1717_com;
1;

__END__

#       vim:filetype=perl


