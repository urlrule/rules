#!/usr/bin/perl -w
#DOMAIN : m.zhongziso.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2018-07-15 01:04
#UPDATED: 2018-07-15 01:04
#TARGET : https://m.zhongziso.com/list/%E4%BD%A0%E5%A5%BD/1 2
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_m_zhongziso_com;
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
	if($url =~ m/([^\/]+:\/\/.+?)\/\??(.+)$/) {
		$rurl = $1 . "/list/$2/1";
	}
    return (
        pass_count=>1,
        pass_data=>[$rurl],
        base=>$rurl,
    );
}

return new MyPlace::URLRule::Rule::2_m_zhongziso_com;
1;

__END__

#       vim:filetype=perl


