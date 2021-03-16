#!/usr/bin/perl -w
#DOMAIN : hifiporn.cc
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2020-12-25 15:10
#UPDATED: 2020-12-25 15:10
#TARGET : https://hifiporn.cc/xxx/mom 1
#URLRULE: 2.0
package MyPlace::URLRule::Rule::1_hifiporn_cc;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

=method1
sub apply_rule {
	my $self = shift;
	return $self->apply_quick(
	   'data_exp'=>undef,
	   'data_map'=>undef,
       'data_exp'=>'class="thumbed"><a[^>]+href="([^"]+)',
       'data_map'=>'"urlrule:$1"',
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

use MyPlace::WWW::Utils qw/get_url get_safename url_getname url_getbase/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
	my $html = get_url($url,'-v');
    my @data;
    my @pass_data;
	my $host = url_getbase($url);
	while($html =~ m/class="thumbed"><a[^>]+href="([^"]+)/g) {
		my $y = $1;
		if($y =~ m/^\//) {
			push @data,"urlrule:" . $host . $y . "\t" . url_getname($y) . ".mp4";
		}
		else {
			push @data,"urlrule:" . $y . "\t" . url_getname($y) . ".mp4";
		}
	}
    return (
        base=>$url,
        count=>scalar(@data),
        data=>\@data,
        title=>undef,
    );
}

return new MyPlace::URLRule::Rule::1_hifiporn_cc;
1;

__END__

#       vim:filetype=perl


