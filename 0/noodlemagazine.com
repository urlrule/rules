#!/usr/bin/perl -w
#DOMAIN : noodlemagazine.com
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2021-02-23 04:31
#UPDATED: 2021-02-23 04:31
#TARGET : https://noodlemagazine.com/watch/-123400772_456252943
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_noodlemagazine_com;
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
use MyPlace::JSON qw/decode_json/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
	my $html = get_url($url,'-v');
    my @data;
    my @pass_data;
	my %info;
    my @html = split(/\n/,$html);
	foreach(@html) {
		if(m/property="og:([^"]+)"[^>]+content="([^>"]+)/) {
			$info{$1} = $2;
		}
	}
	return (error=>"Error paring page") unless($info{video});
	$info{video} =~ s/\/player\//\/playlist\//g;
	$info{playlist} = get_url($info{video},'-v','--referer',$url);
	$info{play} = decode_json($info{playlist});
	return (error=>"Error paring video") unless($info{play}->{sources});
	$info{title} = url_getname($url) unless($info{title});
	$info{title} = get_safename($info{title});
	push @data,$info{play}->{sources}->[0]->{file} . "\t" . $info{title} . ".mp4";
	push @data,$info{image} . "\t" . $info{title} . ".jpg" if($info{image});

    return (
        base=>$url,
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        title=>undef,
    );
}

return new MyPlace::URLRule::Rule::0_noodlemagazine_com;
1;

__END__

#       vim:filetype=perl


