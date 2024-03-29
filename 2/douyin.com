#!/usr/bin/perl -w
#DOMAIN : www.douyin.com
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2018-09-13 23:48
#UPDATED: 2018-09-13 23:48
#TARGET : https://www.douyin.com/share/user/77515940979/?share_type=link 2
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_douyin_com;
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

use MyPlace::Douyin qw/get_url/;
#TARGET : https://www.amemv.com/aweme/v1/aweme/post/?user_id=57720812347&count=21&max_cursor=0&aid=1128&dytk=4830f6e279a5f53872aab9e9dc112d33

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $html = get_url($url);
    my $title = undef;
    my @data;
    my @pass_data;
	my %i;
	if($html =~ m/uid:\s*['"](\d+)['"]/) {
		$i{uid} = $1;
	}
	if(!$i{uid}) {
		return (error=>"Parsing page faile");
	}
	return (
		pass_count=>1,
		pass_data=>["https://www.douyin.com/share/user/$i{uid}/?share_type=link"],
        base=>$url,
	);
}

return new MyPlace::URLRule::Rule::2_douyin_com;
1;

__END__

#       vim:filetype=perl


