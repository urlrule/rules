#!/usr/bin/perl -w
#http://xiangce.baidu.com/picture/album/list/aa1c21bbc7774e5b6a4f27fb07bc0ecd6b235b9c
#Thu Dec  4 02:08:44 2014
use strict;
no warnings 'redefine';

=method1
sub apply_rule {
 return (
       '#use quick parse'=>1,
       'data_exp'=>'picBigSrc\s*:\s*\'([^\']+)',
       'data_map'=>'$1',
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

sub apply_rule {
    my ($url,$rule) = @_;


	my $html = get_url($url,'-v');
	
	my %info;
	while($html =~ m/(\w+)\s*:\s* (?:'([^']+)'|(\d+))/g) {
		$info{$1} = $2 ? $2 : $3;
		last if($1 eq 'curPage');
	}

	return (
		info=>\%info,
	) unless($info{albumSign} || $info{picNum});

	my $jurl = 'http://xiangce.baidu.com/picture/album/list/' .
			$info{albumSign} .
			'?view_type=tile&size=' . 
			$info{picNum} . 
			'&pn=&format=json&type=default&_=' .
			time();
	
	use JSON qw/decode_json/;
	my $json = decode_json(get_url($jurl,'-v'));
	return (
		info=>\%info,
		json=>$json,
	) unless($json->{data} || $json->{data}->{picture_list});

	use Encode qw/find_encoding/;
	my $utf = find_encoding('utf8');
	my @images;
	foreach(@{$json->{data}->{picture_list}}) {
		if($_->{picture_name}) {
			$_->{picture_name} =~ s/\.([^\.]+)$//;
			my $ext = $_->{pic_big_src};
			$ext =~ s/^.*\///;
			$ext = $ext ? "_$ext" : ".jpg";

			push @images,$_->{pic_big_src} . "\t" . $utf->encode($_->{picture_name}) . $ext;
		}
		else {
			push @images,$_->{pic_big_src};
		}
	}

	return (
		count=>scalar(@images),
		data=>\@images,
		title=>$info{albumName},
	);
	


}

=cut

1;

__END__

#       vim:filetype=perl
