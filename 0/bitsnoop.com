#!/usr/bin/perl -w
#http://bitsnoop.com/search/all/%E5%96%82%E5%A5%B6+safe:no/c/d/1/
#Tue Nov  4 01:33:05 2014
use strict;
no warnings 'redefine';


=method 1
sub apply_rule {
 return (
       '#use quick parse'=>1,
       'data_exp'=>undef,
       'data_map'=>undef,
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
	my $title;
	my $magnet;
	my @data;
	if($html =~ m/<a data-cm="1" title="([^"]+)"/) {
		$title = $1;
	}
	elsif($html =~ m/<title>\s*([^<]+?)\s+-[^-]+-\s*Torrent Download\s*\|\s*Bitsnoop</i) {
		$title = $1;
		$title =~ s/[\s\.]+torrent$//;
	}
	if($html =~ m/href\s*=\s*"(magnet:\?[^"]+)"/) {
		if($title) {
			push @data,"$1\t$title";
		}
		else {
			push @data,$1;
		}
	}
    return (
        count=>scalar(@data),
        data=>\@data,
    );
}

=cut

1;

__END__

#       vim:filetype=perl
