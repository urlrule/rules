#!/usr/bin/perl -w
#DOMAIN : txxx.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2019-01-28 02:28
#UPDATED: 2019-01-28 02:28
#TARGET : https://www.txxx.com/videos/65188/darryl-hannah/?fr=65188
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_txxx_com;
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

use MyPlace::URLRule::Utils qw/get_url create_title/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
	my %info;
	if($html =~ m/<a[^>]+href="(.+get_file.+\/)([^\/]+)(\/\?[^"]+)/) {
		$info{fn} = $2;
		$info{url} = "$1$2$3";
		$info{url} =~ s/&amp;/&/g;
		$info{url} =~ s/download=true/f=video.m3u8/;
		my $lt=time;
		$info{url} =~ s/%lock_time%/$lt/;
		$info{url} =~ s/%lock_ip%/120/;
		$info{url} =~ s/:\/\/www\./:\/\/upload./;
	}
	return (error=>"Error parsing page") unless($info{url});
	if($html =~ m/<h2[^>]*>(.+?)<\/\s*h2/) {
		$info{title} = $1;
		$info{title} =~ s/<[^>]+>//g;
		$info{title} = create_title($info{title});
	}
	my $prefix = $info{title} . "_" . $info{fn};
	if($html =~ m/image: '([^']+\.jpg)/) {
		push @data,"$1\t$prefix.jpg";
	}
	push @data,"$info{url}\t$prefix";
    #my @html = split(/\n/,$html);
    return (
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
        title=>$title,
    );
}

return new MyPlace::URLRule::Rule::0_txxx_com;
1;

__END__

#       vim:filetype=perl


