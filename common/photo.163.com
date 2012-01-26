#!/usr/bin/perl

use MyPlace::163::Photo;

sub get_pictures {
	my $album = shift;
	my $pictures = MyPlace::163::Photo->get_pictures($album);
	my @data = map "$_->{url}",@$pictures;
	return (
		data=> \@data,

	) if($pictures);
}

sub apply_rule {
	my ($url,$rule) = @_;
	if((!$rule->{level})) {
		return get_pictures($url);
	}

	#album_js URL
	if($rule->{level} == 1) {
		my $albums = MyPlace::163::Photo->get_albums_from_js($url);
		my $count = 0;
		my @pass_data;
		foreach(@{$albums}) {
			$count++;
			push @pass_data,{url=>$_->{purl},title=>$_->{name}};
		}
		return (
			pass_data=>\@pass_data,
			pass_count=>$count,
		);
	}

	my $hostName = undef;
	if($url =~ m/photo\.163\.com\/photo\/([^\/]+)/) {
		$hostName = $1;
	}
	elsif($url =~ m/photo\.163\.com\/([^\/]+)\/?$/) {
		$hostName = $1;
	}
	if($hostName) {
		my $p163 = new MyPlace::163::Photo(hostName=>$hostName);
		$p163->init();
		return (
			pass_data=> [
				{
					url=>$p163->get_albums_url,
					title=>$p163->title,
				},
			],
		);
	}
}


#	vim:filetype=perl
