#!/usr/bin/perl -w
#DOMAIN : 9ku.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2020-12-23 23:04
#UPDATED: 2020-12-23 23:04
#TARGET : http://9ku.com/play/183176.htm
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_9ku_com;
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

use MyPlace::WWW::Utils qw/get_url get_safename url_getname create_title/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
	my $rurl = $url;
	$rurl =~ s/:\/\/www\./:\/\/m./;
	$rurl =~ s/\/down\//\/play\//;
	my $html = get_url($rurl,'-v');
    my @data;
    my @pass_data;
	my %info;
    my @html = split(/\n/,$html);
	foreach(@html) {
		if(m/property="og:([^"]+)"[^>]+content="([^"]+)"/) {
			$info{$1} = create_title($2);
		}
		if(m/mp3\s*:\s*"([^"]+)/) {
			$info{mp3} = $1;
		}
	}
	if(!$info{mp3}) {
		return (error=>"Parsing page error");
	}
	my $title = $info{mp3};
	$title =~ s/.*\///;
	$title = $info{title} . ".mp3" if($info{title});
	$title = $info{"music:artist"} . " - " . $title if($info{"music:artist"});
	push @data,"$info{mp3}\t$title";
    return (
        base=>$url,
        count=>scalar(@data),
        data=>\@data,
    );
}

return new MyPlace::URLRule::Rule::0_9ku_com;
1;

__END__

#       vim:filetype=perl


