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
	if(m/^u\/(\d+)$/) {
		$uid = $1;
		$profile = "u/$uid";
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
		host=>'weibo.com',
		url=>'http://weibo.com/' . $profile,
	);
}

# vim:filetype=perl

