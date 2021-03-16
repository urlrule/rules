#!/usr/bin/perl -w
#DOMAIN : hifiporn.cc
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2020-12-25 14:54
#UPDATED: 2020-12-25 14:54
#TARGET : https://hifiporn.cc/xxx/2/blowjob/blowjob-queen-ph-award-winner-2018-miss-banana
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_hifiporn_cc;
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

use MyPlace::WWW::Utils qw/get_url get_safename url_getname/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
	my $test_aria2_rpc = 0;
	if($url =~ m/^(.+)#testing_aria2_rpc$/) {
		$url = $1;
		$test_aria2_rpc = 1;
	}
	my $html = get_url($url,'-v');
    my @data;
    my @pass_data;
	my %info;
	while($html =~ m/property="og:([^"]+)"[^>]+content="([^"]+)"/g) {
		$info{$1} = $2;
	}
	while($html =~ m/<(source[^>]+)>/g) {
		my $source = $1;
		next unless($source =~ m/src="([^"]+)/);
		my $video = $1;
		$info{video} = $video unless($info{video});
		$info{video} = $video if($source =~ m/id="sourceHD/);
	}
	if(!$info{video}) {
		return (error=>"Error parsing page");
	}
	$info{title} = url_getname($url);
	push @data,$info{video} . ($test_aria2_rpc ? "#testing_aria2_rpc" : "") . "\t" . $info{title} . ".mp4";
	push @data,$info{image} .  "\t" . $info{title} . ".jpg" if($info{image});
    #my @html = split(/\n/,$html);
    return (
		#		info=>\%info,
        base=>$url,
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        title=>undef,
    );
}

return new MyPlace::URLRule::Rule::0_hifiporn_cc;
1;

__END__

#       vim:filetype=perl


