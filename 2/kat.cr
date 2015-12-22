#!/usr/bin/perl -w
#http://kat.cr/?麻生希
#Wed Jan 14 16:51:11 2015
use strict;
no warnings 'redefine';


=method1
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


sub apply_rule {
    my ($url,$rule) = @_;
	my $realurl = $url;
	if($url =~ m/^(.*)\/\??(.+)$/) {
		my $b = $1;
		my $q = $2;
		$realurl = $b . "/usearch/$q/";
	}
    return (
		count=>0,
		pass_count=>1,
		pass_data=>[$realurl],
    );
}

=cut

1;

__END__

#       vim:filetype=perl
