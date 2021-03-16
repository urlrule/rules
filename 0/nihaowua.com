#!/usr/bin/perl -w
#DOMAIN : nihaowua.com
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2021-02-02 00:35
#UPDATED: 2021-02-02 00:35
#TARGET : https://www.nihaowua.com/v/
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_nihaowua_com;
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

use MyPlace::WWW::Utils qw/get_url get_safename url_getname url_getbase expand_url/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
    my @data;
    my @pass_data;
	my $base = url_getbase($url);
	my $vurl = $base . "/v/video.php?t=" . time();
	my $nurl = expand_url($vurl);
	if($nurl ne $vurl) {
		my $title = $nurl;
		$title =~ s{^.*?/(\d+)/}{$1};
		$title =~ s{\?.+$}{};
		$title =~ s{/(\d+)}{$1}g;
		$title =~ s{/}{_}g;
		push @data,$nurl . "\t" . $title;
		push @pass_data,$url;
	}
    #my @html = split(/\n/,$html);
    return (
        base=>$url,
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        title=>undef,
		level=>0,
    );
}

return new MyPlace::URLRule::Rule::0_nihaowua_com;
1;

__END__

#       vim:filetype=perl


