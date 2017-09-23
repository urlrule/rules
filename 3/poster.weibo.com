#!/usr/bin/perl -w
#DOMAIN : posts.weibo.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2017-09-20 02:03
#UPDATED: 2017-09-20 02:03
#TARGET : https://posts.weibo.com/{UID}
#URLRULE: 2.0
package MyPlace::URLRule::Rule::3_poster_weibo_com;
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
	my $title = $url;
	my $range = "posts";
	if($url =~ m/\/[^\/]*?(\d+)[^\/]*\/(posts|likes|all)\/*$/) {
		$title = $1;
		$range = $2;
	}
	elsif($url =~ m/\/[^\/]*?(\d+)[^\/]*$/) {
		$title = $1;
	}
	else {
		return (error=>"Invalid url\n");
	}
	my @pass_data;
	if($range eq 'all') {
		push @pass_data,"http://likes.weibo.com/$title";
		push @pass_data,"http://posts.weibo.com/$title";
	}
	elsif($range eq 'likes') {
		push @pass_data,"http://likes.weibo.com/$title";
	}
	else {
		push @pass_data,"http://posts.weibo.com/$title";
	}
	return (
		pass_data=>[@pass_data],
		pass_count=>scalar(@pass_data),
		base=>'https://m.weibo.cn/' . $title,
	);
}

return new MyPlace::URLRule::Rule::3_poster_weibo_com;
1;

__END__

#       vim:filetype=perl


