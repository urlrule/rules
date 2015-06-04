#!/usr/bin/perl -w
use strict;
my %opts;

if($ARGV[0]) {
	if($ARGV[0] eq '--id') {
		$opts{id} = 1;
		shift;
	}
	elsif($ARGV[0] eq '--name') {
		$opts{name} = 1;
		shift;
	}
	else {
		$opts{id} = $opts{name} = 1;
	}
}

my @id;
my %info;
while(<>) {
	chomp;
	if(m/href="\/user\/([^\/"\?]+)"[^>]+title="([^"]+)/) {
		next if($info{$1});
		unshift @id,$1;
		$info{$1} = $2;
	}
}

foreach (@id) {
	if($opts{id}) {
		print $_;
	}
	if($opts{id} and $opts{name}) {
		print "\t$info{$_}";
	}
	elsif($opts{name}) {
		print $info{$_};
	}
	print "\n";
}
