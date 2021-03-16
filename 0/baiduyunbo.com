#!/usr/bin/perl -w
#DOMAIN : baiduyunbo.com
#AUTHOR : eotect <eotect@MYPLACE>
#CREATED: 2020-02-14 03:15
#UPDATED: 2020-02-14 03:15
#TARGET : https://baiduyunbo.com/?id=w3H0lfRP
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_baiduyunbo_com;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

=method1
sub apply_rule {
	my $self = shift;
	return $self->apply_quick(
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
	   'pages_limit'=>undef,
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
	);
}
=cut

use MyPlace::WWW::Utils qw/get_url get_safename url_getname/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
	if($html =~ m/var m3u8url = '([^']+)'\s*\+getQueryString\('id'\)\+'\.m3u8'/) {
		my $host = $1;
		my $id = $url;
		$id =~ s/.*[&\?]id=([^&]+).*/$1/;
		push @data,"m3u8:$host$id.m3u8\t$id.ts"
	}
    return (
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$title,
    );
}

return new MyPlace::URLRule::Rule::0_baiduyunbo_com;
1;

__END__

#       vim:filetype=perl


