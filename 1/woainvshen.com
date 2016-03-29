#!/usr/bin/perl -w

#DOMAIN : lunvshen.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2016-01-09 01:36
#UPDATED: 2016-01-09 01:36
#TARGET : http://lunvshen.com/u?name=穆晹MOYI 1

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
       'pass_exp'=>'<a[^>]+class="imga boxer"[^>]+href=\'([^\']+)\'|<p[^>]+class=\'go-to-next-page\'>[^<]*<a[^>]+href=\'([^\']+)',
       'pass_map'=>'$1 || $2',
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
    my $title = undef;
    my @data;
    my @pass_data;
	if($url =~ m/wb\?id=\d+/) {
		return (
			pass_count=>1,
			pass_data=>[$url],
			base=>$url,
			count=>0,
		);
	}
	my $html = get_url($url,'-v');
	while($html =~ m'<a[^>]+class="imga boxer"[^>]+href="([^"]+)"'g) {
		push @pass_data,$1;
	}
	if($html =~ m'<p[^>]+class=\'go-to-next-page\'>[^<]*<a[^>]+href=\'([^\']+)') {
		push @pass_data,$1;
	}
    return (
        count=>0,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
		same_level=>1,
    );
}

=cut

1;

__END__

#       vim:filetype=perl


