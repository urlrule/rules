#!/usr/bin/perl -w
#DOMAIN : saveig.org
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2019-11-06 02:31
#UPDATED: 2019-11-06 02:31
#URLRULE: 2.0
package MyPlace::URLRule::Rule::info_shoplineapp_com;
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
	my $host;
	my $id;
	my $uname;
	if($url =~ m/https?:\/\/([^\.]+)\.([^\/]+)/) {
		$host = $2;
		$id = $1;
		$uname = $id;
	}
    return (
        base=>$url,
		profile=>$id,
		uname=>ucfirst($uname),
		host=>$host,
		id=>$id,
    );
}

return new MyPlace::URLRule::Rule::info_shoplineapp_com;
1;

__END__

#       vim:filetype=perl


