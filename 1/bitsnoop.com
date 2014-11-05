#!/usr/bin/perl -w
#http://bitsnoop.com/search/all/%E5%96%82%E5%A5%B6+safe:no/c/d/1/
#Tue Nov  4 01:33:05 2014
use strict;
no warnings 'redefine';


sub apply_rule {
 return (
       '#use quick parse'=>1,
       'data_exp'=>undef,
       'data_map'=>undef,
       'pass_exp'=>'<\/span>\s*<a href="(\/[^"]+-q\d+\.html)',
       'pass_map'=>'$1',
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

=method 2
use MyPlace::URLRule::Utils qw/get_url/;
use Encode qw/find_encoding/;
my $utf = find_encoding('utf8');

sub apply_rule {
    my ($url,$rule) = @_;
	my $html = $utf->decode(get_url($url,'-v'));
	my $title;
	my $hash;
	my @data;
	if($html =~ m/<title>\s*([^<]+?)\s+-[^-]+-\s*Torrent Download\s*\|\s*Bitsnoop</i) {
		$title = $1;
		$title =~ s/[\s\.]+torrent$//;
	}
	if($html =~ m/magnet:\?[^"]*?xt=urn:btih:([^:&]+)/) {
		$hash = uc($1);
		push @data, ($title ? "$hash\t$title" : $hash);
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
