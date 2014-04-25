#!/usr/bin/perl -w
use strict;
my $OUTPUT='ID.txt';
my %incoming;
#use Encode qw/find_encoding/;
#my $utf8 = find_encoding("utf8");
my @IdSorted;
while(<>) {
	chomp;
#	$_ = $utf8->decode($_);
	if(m/^([^\s]+)\s+([^\s]+)\s*$/) {
		push @IdSorted,$1 unless($incoming{$1});
		$incoming{$1} = $2;
	}
}

my %id;
open FI,"<",$OUTPUT;
while(<FI>) {
	chomp;
#	print Dumper($_),"\n";
	if(m/^#([^\s]+)\s+([^\s]+)\s*$/) {
		$id{$1} = $2;
	}
	elsif(m/^([^\s]+)\s+([^\s]+)\s*$/) {
		$id{$1} = $2;
	}
}
close FI;
#use Data::Dumper;
#die Dumper(\%id);
open FO,">>",$OUTPUT;

my $count = 0;
foreach (@IdSorted) {
	if($id{$_}) {
		#print STDERR "ID $_($id{$_}) exists in $OUTPUT, Ignored.\n";
	}
	else {
		$count++;
		print FO "$_\t$incoming{$_}\n";
	}
}
if($count > 0) {
	my $t = localtime;
	print STDERR "# $count ID added, ",$t,".\n";
	print FO "# $count ID added, ",$t,".\n\n";
}
else {
	print STDERR "No new ID found\n";
}
close FO;
