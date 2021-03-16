#!/usr/bin/perl -w
#DOMAIN : www.nvshens.com
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2018-08-31 02:59
#UPDATED: 2018-08-31 02:59
#TARGET : https://www.nvshens.com/girl/16293/ 1
#URLRULE: 2.0
package MyPlace::URLRule::Rule::1_www_nvshens_com;
use MyPlace::URLRule::Utils qw/get_url/;
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


sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $rurl = $url;
	#	$rurl = $url . "/album/" unless($url =~ m/\/album\//);
	#	$rurl =~ s{//}{/}g;
	my $html = get_url($rurl,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
	while($html =~ m/<a class='igalleryli_link'[^>]+href=["']([^"']+)/g) {
		push @pass_data,$1;
	}
    return (
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
    );
}

return new MyPlace::URLRule::Rule::1_www_nvshens_com;
1;

__END__

#       vim:filetype=perl


