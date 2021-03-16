#!/usr/bin/perl -w
#DOMAIN : www5.javwide.com
#AUTHOR : eotect <eotect@MYPLACE>
#CREATED: 2019-05-22 00:53
#UPDATED: 2019-05-22 00:53
#TARGET : https://www5.javwide.com/embed/xQgZd
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_www5_javwide_com;
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
use JSON qw/decode_json/;
sub safe_decode_json {
	my $json = eval { decode_json($_[0]); };
	if($@) {
		print STDERR "Error deocding JSON text:$@\n";
		$@ = undef;
		return {};
	}
	else {
		if($json->{reason}) {
			print STDERR "Error: " . $json->{reason},"\n";
		}
		return $json;
	}
}


sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $rurl = $url;
	$rurl =~ s/:\/\/([^\/]+)\//:\/\/www5.javwide.com\//;
	my $html = get_url($rurl,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
	my %info;
	if($html =~ m/id="redirector"\s+data-key="([^"]+)"/) {
		$info{data_url} = $1;
	}
	if(!$info{data_url}) {
		return (error=>"parsing page error");
	}
	if($html =~ m/name="title"\s+content="([^"]+)"/) {
		$title = get_safename($1);
		$title =~ s/^(?:WATCH[_\s]*JAV|WATCH|JAV)[_\s]+//ig;
	}
	$info{data_url} =~ s/\/v\//\/api\/source\//;
	print STDERR "Using $info{data_url}\n";
	$info{data_json} = get_url($info{data_url},"-v","--form-string","r=&d=www.embed.media");
	$info{json} = safe_decode_json($info{data_json});
	if($info{json}->{data}) {
		$info{json} = $info{json}->{data};
	}
	if(!$info{json}) {
		return (error=>"no data found");
	}
	$info{label} = 0;
	foreach(@{$info{json}}) {
		$_->{label} =~ s/[^\d]+//g;
		if($_->{label}>$info{label}) {
			$info{label} = $_->{label};
			$info{video} = $_->{file};
			$info{ext} = "." . $_->{type};
		}
	}
	$info{label} = $info{label} ? "_" . $info{label} . "p" : "";
	push @data,$info{video} . "\t" . $title . $info{ext};

    #my @html = split(/\n/,$html);
    return (
		#		info=>\%info,
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
    );
}

return new MyPlace::URLRule::Rule::0_www5_javwide_com;
1;

__END__

#       vim:filetype=perl


