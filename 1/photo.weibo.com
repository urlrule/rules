#!/usr/bin/perl -w

#DOMAIN : photo.weibo.com
#AUTHOR : Eotect Nahn <eotect@myplace>
#CREATED: 2016-04-08 00:02
#UPDATED: 2016-04-08 00:02
#TARGET : ___TARGET___

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

use MyPlace::Weibo::Photo qw/get_photos get_url/;

sub apply_rule {
    my ($url,$rule) = @_;

	my %album = (id=>0);
	my @pass_data;
	my $title;
	my $html = get_url($url,'-v');
	if($html =~ m/<title>[^\|]+\|(.+?) - [^-]+<\/title>/) {
		$album{caption} = $1;
	}
	$html =~ s/.*this\.\$GLOBAL_DETAIL//s;
	$html =~ s/<\/script>.*$//s;
	foreach(qw/album_id caption cover_pic/) {
		next if($album{$_});
		if($html =~ m/"$_":"([^"]+)"/) {
			$album{$_} = $1;
		}
	}
	if($html =~ m/"photos":\s*(\d+)\s*/) {
		$album{photos} = $1;
	}
	if($url =~ m/\/album_id\/(\d+)/) {
		$album{album_id} = $1;
	}
	if(!$album{album_id}) {
		return (error=>'Invalid URL',album=>\%album);
	}

	if(!$album{photos}) {
		return (error=>'Empty album',album=>\%album);
	}
	my $pages = $album{photos} / 30;
	$pages++ if($album{photos} % 30);
	
	foreach(1 .. $pages) {
		push @pass_data,'http://photo.weibo.com/photos/get_all?' .
				join("&",
					"album_id=$album{album_id}",
					"count=30",
					"page=$_",
					"type=1",
					"__rnd=" . time . '794'
				)
		;
	}
    return (
		album=>\%album,
        count=>0,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$album{caption},
    );
}

=cut

1;

__END__

#       vim:filetype=perl



