#!/usr/bin/perl -w
#DOMAIN : btbiti.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2017-12-30 01:41
#UPDATED: 2017-12-30 01:41
#TARGET : btbiti.com 2
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_btbiti_com;
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
	my $https;
    my @pass_data;
	if($url =~ m/^https:/) {
		$https = 1;
	}
	if($url =~ m/^https?:\/\/[^\/]+\/(.+)$/) {
		my $q = $1;
		$q =~ s/\+/ /g;
		push @pass_data,($https ? 'https' : 'http' ) . '://btbiti.com/search/' . $q . '.html';
	}
    my $title = undef;
    my @data;
    #my @html = split(/\n/,$html);
    return (
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$title,
    );
}

return new MyPlace::URLRule::Rule::2_btbiti_com;
1;

__END__

#       vim:filetype=perl


