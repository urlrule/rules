#!/usr/bin/perl -w
#DOMAIN : www.fk5378.com
#AUTHOR : eotect <eotect@MYPLACE>
#CREATED: 2019-01-25 22:25
#UPDATED: 2019-01-25 22:25
#TARGET : https://www.fk5378.com/video/3051
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_www_fk5378_com;
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
    #my @html = split(/\n/,$html);
	my %info;
	while($html =~ m/property="(?:og|article):([^"]+)"[^>]+content="([^"]+)/g) {
		$info{$1}=$2;
	}
	if($html =~ m/source[^>]+src="([^"]+\.mp4)"/) {
		$info{video}=$1;
		$info{video} =~ s/http:\/\//https:\/\//;
	}
	return (error=>"Error parsing page, no video found") unless($info{video});
	if($info{title}) {
		$info{title} =~ s/\s+\|.*$//;
		$info{title} = create_title($info{title});
	}
	if($info{url}) {
		$info{url} =~ s/^.*\/(\d+)[^\d]*$/$1/;
		$info{title} = $info{title} ? $info{url} . "_" . $info{title} : $info{url};
	}
	if($info{published_time}) {
		$info{published_time} =~ s/[- _]//g;
		$info{title} = $info{title} ? $info{published_time} . "_" . $info{title} : $info{published_time};
	}

	push @data,$info{video} . ($info{title} ? "\t$info{title}.mp4" : "");
	if($info{image}) {
		$info{image} =~ s/http:\/\//https:\/\//;
		push @data,$info{image} . ($info{title} ? "\t$info{title}.jpg" : "");
	}
	
    return (
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$title,
    );
}

return new MyPlace::URLRule::Rule::0_www_fk5378_com;
1;

__END__

#       vim:filetype=perl


