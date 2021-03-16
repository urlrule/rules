#!/usr/bin/perl -w
#DOMAIN : tom203.com
#AUTHOR : eotect <eotect@MYPLACE>
#CREATED: 2020-02-14 01:14
#UPDATED: 2020-02-14 01:14
#TARGET : https://tom203.com/e/search/index.php?keyboard=抖音&show=title&tbname=movie&tempid=1 3
#URLRULE: 2.0
package MyPlace::URLRule::Rule::3_tom203_com;
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

use MyPlace::WWW::Utils qw/get_url_redirect/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
    my @pass_data;
	my $post_url;
	my $post_data;
	if($url =~ m/^([^\?]+)\?(.+)$/) {
		$post_url = $1;
		$post_data = $2;
	}
	$post_url = $url unless($url);
	my $next_url = get_url_redirect($post_url,$post_data);
	push @pass_data,$next_url if($next_url);
    return (
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
    );
}

return new MyPlace::URLRule::Rule::3_tom203_com;
1;

__END__

#       vim:filetype=perl


