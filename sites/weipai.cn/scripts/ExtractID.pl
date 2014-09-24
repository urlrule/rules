#!/usr/bin/perl -w
use strict;
my %id;
while(<>) {
	chomp;
	if(m/href="\/user\/([^\/"\?]+)"[^>]+title="([^"]+)/) {
		$id{$1} = $2;
	}
}

foreach (keys %id) {
	print $_,"\t",$id{$_},"\n";
}
