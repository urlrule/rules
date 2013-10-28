#!/usr/bin/perl -w

sub apply_rule {
	my $url = shift;
	return (
		base=>$url,
		pass_data=> [map "vod-show-id-$_.html",(8,9,10,11,12,13,14,15,16,17,18,3,4,5,23,24)]
	);
}

# vim:filetype=perl

