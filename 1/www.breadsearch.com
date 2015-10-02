#!/usr/bin/perl -w

#DOMAIN : www.breadsearch.com
#AUTHOR : eotect <eotect@myplace>
#CREATED: 2015-09-28 00:10
#UPDATED: 2015-09-28 00:10
#TARGET : ___TARGET___

use strict;
no warnings 'redefine';

=method1
sub apply_rule {
 return (
 #Set quick parsing method on
       '#use quick parse'=>1,

#Specify data mining method
       'data_exp'=>undef,
       'data_map'=>undef,

#Specify data mining method for nextlevel
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,

#Specify pages mining method
       'pages_exp'=>'totalPages:\s*(\d+)\s*,'
       'pages_map'=>'$1',
       'pages_pre'=>/,
       'pages_suf'=>undef,
       'pages_start'=>undef,
	   'pages_limit'=>undef,

       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
 );
}
=cut

use MyPlace::URLRule::Utils qw/get_url/;

sub apply_rule {
    my ($url,$rule) = @_;
    my @pass_data;
	my $prefix;
	if($url =~ m/\/search\/([^\/]+)/) {
		$prefix = "/search/$1/";
	}
	else {
		return (
			error=>"Parse url failed: $url\n",
		);
	}
	my $html = get_url($url,'-v');
	return (error=>"Failed parsing html content: $url\n")
		unless($html =~ m/totalPages\s*:\s*(\d+)\s*,/);
	my $max = $1;
	for my $page( 1 .. $max) {
		push @pass_data,$prefix . $page;
	}
    return (
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
    );
}

=cut

1;

__END__

#       vim:filetype=perl



