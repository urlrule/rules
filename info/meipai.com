#!/usr/bin/perl -w
use strict;
use warnings;

sub apply_rule {
	my $url = shift;

	my $uid;
	my $profile;
	my $uname;

	my $path = $url;
	$path =~ s/^https?:\/\/[^\/]+\///;
	$path =~ s/[\?\&\#].+$//;
	$_ = $path;
	if(m/^user\/(\d+)$/) {
		$uid = $1;
		$profile = "$uid";
	}
	elsif(m/^([^\/\&\?]+)/) {
		$uname = $1;
		$profile = $uname;
	}
	elsif(m/^p\/\d\d\d\d\d(\d+)/) {
		$uid = $1;
		$profile = "u/$uid";
	}

	return (
		uid=>$uid,
		uname=>$uname,
		profile=>$profile,
		host=>'meipai.com',
		url=>'http://www.meipai.com/user/' . $profile,
	);
}

# vim:filetype=perl

