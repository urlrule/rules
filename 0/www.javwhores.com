#!/usr/bin/perl -w
#DOMAIN : www.javwhores.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2019-01-26 02:03
#UPDATED: 2019-01-26 02:03
#TARGET : https://www.javwhores.com/video/61989/1pondo-010319-792-kamiyama-nana-m-slut-women
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_www_javwhores_com;
use MyPlace::URLRule::Utils qw/get_url create_title/;
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
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
	my %info;
	while($html =~ m/property="og:([^"]+)"[^>]+content="([^"]+)/g) {
		$info{$1} = $2;
	}
	while($html =~ m/(video_url|postfix|preview_url|video_alt_url2|video_alt_url):\s*'([^']+)/g) {
		$info{$1} = $2;
	}
	$info{video} = $info{video_alt_url2} || $info{video_alt_url} || $info{video_url};
	return (error=>"Error parsing video from page",info=>\%info) unless($info{video});
	if(!$info{title}) {
		$info{title} = $url;
		$info{title} =~ s/^.*\///;
		$info{title} =~ s/[\?#].*$//;
	}
	$info{ext} = $info{postfix} || ".mp4";
	$info{title} = create_title($info{title});
	push @data,$info{video} . "\t" . $info{title} . $info{ext};
	push @data,$info{preview_url} . "\t" . $info{title} . ".jpg" if($info{preview_url});
    #my @html = split(/\n/,$html);
    return (
		i=>\%info,
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
    );
}

return new MyPlace::URLRule::Rule::0_www_javwhores_com;
1;

__END__

#       vim:filetype=perl


