#!/usr/bin/perl -w
#77soso.com
#Sun Oct 27 02:14:46 2013
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

use MyPlace::URLRule::Utils qw/get_url get_html/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_html($url,'-v');
    my @pass_data;
	my @pass_name;
	my $curname;
	my %links;
	while($html =~ m/<[aA][^>]*href\s*=\s*["']([^"']+)["'][^>]*>([^<]+)</g) {
		if($1 eq '/') {
			$curname = $2;
		}
		else {
			my $url = $1;
			if($url =~ m/\/list\/index\d+\.html$/) {
				$links{$url} = $curname || '' unless($links{url});
			}
		}
	}
    return (
        count=>0,
        pass_count=>scalar(@pass_data),
        pass_data=>[keys %links],
		pass_name=>[values %links],
        base=>$url,
		url=>$url,
    );
}

=cut

1;

__END__

#       vim:filetype=perl
