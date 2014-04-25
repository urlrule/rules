#!/usr/bin/perl -w
use strict;
my %id;
my @text = <>;
my @IdSorted;
foreach(@text) {
	chomp;
	if(m/href="[^"]*\/ta\/qs\/([^"&\?\/]+)"[^>]*>([^<]+)/) {
		push @IdSorted,$1 unless($id{$1});
		$id{$1} = $2;
	}
}
my $text = join('',@text);
while($text =~ m/href="[^"]*\/ta\/qs\/([^"&\?\/]+)".*?nickName:'([^']+)'/g) {
	push @IdSorted,$1 unless($id{$1});
	$id{$1} = $2;
}

foreach (@IdSorted) {
	print $_,"\t",$id{$_},"\n";
}
