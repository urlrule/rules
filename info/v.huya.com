#!/usr/bin/perl -w
#DOMAIN : v.huya.com
#AUTHOR : Eotect Nahn <eotect@myplace>
#CREATED: 2021-03-17 04:54
#UPDATED: 2021-03-17 04:54
#TARGET : ___TARGET___
#URLRULE: 2.0
package MyPlace::URLRule::Rule::___ID___;
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

use MyPlace::WWW::Utils qw/get_url get_safename url_getname new_url_data/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
	my $html = get_url($url,'-v');
    my @data;
    my @pass_data;
	my %info;
	if($url =~ m{/u/(\d+)}) {
		%info = (
			uid=>$1,
			profile=>"u/$1",
			host=>'huya.com',
		);
	}
	if($html =~ m/class='detail-nick'[^>]*><span>([^<]+)/) {
		$info{uname} = get_safename($1);
	}
    #my @html = split(/\n/,$html);
    return (
		%info,
    );
}

return new MyPlace::URLRule::Rule::___ID___;
1;

__END__

#       vim:filetype=perl



