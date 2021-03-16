#!/usr/bin/perl -w
#DOMAIN : javwide.com
#AUTHOR : eotect <eotect@MYPLACE>
#CREATED: 2019-05-22 01:19
#UPDATED: 2019-05-22 01:19
#TARGET : https://javwide.com 1
#URLRULE: 2.0
package MyPlace::URLRule::Rule::1_javwide_com;
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

use MyPlace::URLRule::Utils qw/get_url get_safename url_getname url_getfull url_getinfo/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $rurl = $url;
	$rurl =~ s/:\/\/([^\/]+)\//:\/\/www5.javwide.com\//;
	my $html = get_url($rurl,'-v');
    my $title = undef;
    my @data;
	my %info;
	if($html =~ m/<iframe[^>]+src="([^"]+\/embed\/[^"]+)"/) {
		$info{data_url} = $1;
	}
	if(!$info{data_url}) {
		return (error=>"parsing page error");
	}
	my ($base,$path,$name) = url_getinfo($url);
	$info{data_url} = url_getfull($info{data_url},$url,$base,$path);
	if($html =~ m/name="title"\s+content="([^"]+)"/) {
		$title = get_safename($1);
		$title =~ s/^(?:WATCH[_\s]*JAV|WATCH|JAV)[_\s]+//ig;
	}
	if(!$title) {
		$title = urlrule_getname($url);
	}
	push @data,"urlrule:" . $info{data_url} . "\t" . $title . ".mp4";
    return (
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
    );
}

return new MyPlace::URLRule::Rule::1_javwide_com;
1;

__END__

#       vim:filetype=perl


