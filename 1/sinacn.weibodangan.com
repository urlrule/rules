#!/usr/bin/perl -w

#DOMAIN : sinacn.weibodangan.com
#AUTHOR : Eotect Nahn <eotect@myplace>
#CREATED: 2016-01-06 03:52
#UPDATED: 2016-01-06 03:52
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
       'pages_exp'=>undef,
       'pages_map'=>undef,
       'pages_pre'=>undef,
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
	my $html = get_url($url,'-v');
	my $t = time;
	my @pass_data= ($url);
	if($html =~ m/<a[^>]+id="next_page"[^>]+href="([^"]+)"/) {
		my $n = $1;
		$n =~ s/#[^\/]+$//;
		$n = $n . "&t" . $t;
		push @pass_data,$n;
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



