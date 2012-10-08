#!/usr/bin/perl -w
#http://weibo.com/yanglu923
#Sat Feb  4 02:19:41 2012
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

use MyPlace::URLRule::Utils qw/get_url/;

sub apply_rule {
    my ($url,$rule) = @_;

	sub from_id {
		return (
			pass_data=>['http://weitu.sdodo.com/user-' . $_[0] . '-1.html'],
			pass_count=>1
		);
	};

	if($url =~ m/weibo\.com\/(\d+)/) {
		return from_id($1);
	}
	my $html = get_url($url,'-v');
	if($html =~ m/href="[^"]*\/(\d+)\/follow/) {
		return from_id($1);
	}
    return (
		count=>0,
		pass_count=>0
    );
}

=cut

1;

__END__

#       vim:filetype=perl
