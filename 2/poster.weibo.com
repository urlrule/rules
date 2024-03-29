#!/usr/bin/perl -w
#DOMAIN : m.weibo.cn
#AUTHOR : eotect <eotect@MYPLACE>
#CREATED: 2019-11-02 18:52
#UPDATED: 2019-11-02 18:52
#TARGET : https://m.weibo.cn/u/7124427103 2
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_m_weibo_cn;
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

use MyPlace::URLRule::Utils qw/get_url get_safename url_getname/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $oid;
	foreach(
		qr/m\.weibo\.cn\/(\d+)/,
		qr/weibo\.com\/(\d+)/,
		qr/m\.weibo\.cn\/(?:u|profile)\/(\d+)/,
		qr/weibo\.com\/(?:u|profile)\/(\d+)/,
		qr/containerid=\d\d\d\d\d\d(\d+)/,
		qr/m\.weibo\.cn\/p\/230413(\d+)/,
	) {
		if($url =~ $_) {
			$oid = $1;
			last;
		}
	}
	if($oid) {
		my $nurl = 'https://m.weibo.cn/api/container/getIndex?containerid=230413' . 
			$oid . '_-_WEIBO_SECOND_PROFILE_WEIBO&page_type=03&page=1';
		return (
			pass_data=>[$nurl],
			pass_count=>1,
			base=>$url,
			title=>$oid,
			link_mtm=>'../../../../.mtm/done.txt',
		);
	}
	else {
		return (error=>"Invalild URL");
	}
}

return new MyPlace::URLRule::Rule::2_m_weibo_cn;
1;

__END__

#       vim:filetype=perl


