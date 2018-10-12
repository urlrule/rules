#!/usr/bin/perl -w
#DOMAIN : www.amemv.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2018-09-13 02:48
#UPDATED: 2018-09-13 02:48
#TARGET : https://www.amemv.com/aweme/v1/aweme/post/?user_id=57720812347&count=21&max_cursor=0&aid=1128&dytk=4830f6e279a5f53872aab9e9dc112d33
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_www_amemv_com;
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

use MyPlace::Douyin qw/get_info get_posts_from_url/;
sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
    my $title = undef;
    my @data;
    my @pass_data;
	my %info;
	if($url =~ m/\/aweme\/v\d+\//) {
		%info = get_posts_from_url($url);
	}
	else {
		%info = get_info($url);
	}
	foreach my $v(@{$info{posts}}) {
		next unless($v->{aweme_id});
		push @data,$v->{video} . "\t" . $info{user_id} . "_" . $v->{aweme_id} . ".mp4";
		my $idx = 1;
		foreach my $i(@{$v->{images}}) {
			push @data,$i . "\t" . $info{user_id} . "_" . $v->{aweme_id} . ".jpg";
			last;
			push @data,$i . "\t" . $info{user_id} . "_" . $v->{aweme_id} . "_$idx.jpg";
			$idx++;
		}
	}
	if($info{has_more} and $info{max_cursor}) {
		my $nurl = $url;
		$nurl =~ s/max_cursor=\d+/max_cursor=$info{max_cursor}/;
		push @pass_data,$nurl;
	}
    return (
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
		samelevel=>1,
        base=>$url,
        title=>$title,
    );
}

return new MyPlace::URLRule::Rule::0_www_amemv_com;
1;

__END__

#       vim:filetype=perl


