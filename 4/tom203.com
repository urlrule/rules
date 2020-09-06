#!/usr/bin/perl -w
#DOMAIN : tom203.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2020-02-14 01:36
#UPDATED: 2020-02-14 01:36
#TARGET : tom203.com 4
#URLRULE: 2.0
package MyPlace::URLRule::Rule::4_tom203_com;
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

use MyPlace::WWW::Utils qw/get_url url_getbase get_safename url_getname/;


sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
    my $title = undef;
    my @pass_data;
	my @pass_name;
    #my @html = split(/\n/,$html);
	my @catas = (
		'VIP','/vipzhuanqu',
		'自拍偷拍','/e/action/ListInfo.php?&classid=52&ph=1&fenlei=4&=',
		'人妻群交','/e/action/ListInfo.php?&classid=52&ph=1&fenlei=5&=',
		'热门事件','/e/action/ListInfo.php?&classid=52&ph=1&fenlei=6&=',
		'网红主播','/e/action/ListInfo.php?&classid=52&ph=1&fenlei=7&=',
		'经典三级','/e/action/ListInfo.php?&classid=52&ph=1&fenlei=8&=',
		'日韩','/yazhouqingse/',
		'欧美','/oumeixingai/',
		'动漫','/chengrendongman/',
		'写真','/meinvxiezhen/',
	);
	my $base = url_getbase($url);
	while(@catas) {
		push @pass_name,shift(@catas);
		push @pass_data,$base . shift(@catas);
	}
    return (
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
		pass_name=>\@pass_name,
		level=>2,
        base=>$url,
    );
}

return new MyPlace::URLRule::Rule::4_tom203_com;
1;

__END__

#       vim:filetype=perl


