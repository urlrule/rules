#!/usr/bin/perl -w
#DOMAIN : ddxzp.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2020-02-15 00:58
#UPDATED: 2020-02-15 00:58
#TARGET : http://ddxzp.com/Video/STP12486
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_ddxzp_com;
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

use MyPlace::WWW::Utils qw/url_getfull get_url get_safename url_getname create_title_utf8/;
my $AUTH = "Authorization:Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzaWQiOiI3Nzk3MzZhNy0zMDg2LTRhOTctYTMyOC0zZWM5ZTMxMzE4YWIiLCJqdGkiOiJjMTQ1NmY4MC02MWY3LTQwM2YtOGJhMy0wOGU3NmFiMjQ3NTkiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoidi11c2VyIiwibGFuZyI6ImNuIiwiYnJhbmRJZCI6IlNORiIsIlZpcnR1YWxVc2VyIjoiVHJ1ZSIsIlZJUFVzZXIiOiJGYWxzZSIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6Ikd1ZXN0IiwiZXhwIjoxNTgxNzA5Mjc1LCJpc3MiOiI0MTRlMTkyN2EzODg0ZjY4YWJjNzlmNzI4MzgzN2ZkMSIsImF1ZCI6InBob2VuaXhpbnRlcmFjdGl2ZSJ9.FmBleHoGje26dacmN3_CVhgBhZf138jZrFWqFaMV-10";
sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
	my %info;
	foreach(qw/cid name/) {
		if($html =~ m/\s*"videoInfo"\s*:\{[^\{\}]*"$_"\s*:\s*"([^"]+)"/) {
			$info{$_} = $1;
		}
	}
	return (error=>"Error parsing video") unless($info{cid} && $info{name});
	print STDERR "VIDEO [$info{cid}] : $info{name}\n";
	my $play_url = url_getfull("/api/video/" . $info{cid} . '/play',$url);
	my $data = get_url($play_url,'-v','-H',$AUTH,'--referer',$url);
	my $play_list;
	if($data =~ m/"videoUrl"\s*:\s*"([^"]+)/) {
		$play_list = url_getfull($1,$url);
	}
	if($data =~ m/"playType"\s*:\s*"TrailPlay"/) {
		my $err = "Video for VIP only";
		return (error=>$err);
	}
	$info{playlist} = $play_list;
	return (error=>"Error parsing video") unless($info{playlist});
	$data = get_url($play_list,'-v','--referer',$url);
	foreach(split(/[\r\n]+/,$data)) {
		if(m/.*m3u8*/) {
			$info{playlist} = url_getfull($_,$info{playlist});
			last;
		}
	}
	return (error=>"Error parsing video") unless($info{playlist});
	push @data,join("\t",(
				'm3u8:' . $info{playlist},
				create_title_utf8($info{name}) . "_" . $info{cid} . ".ts",
				"--referer",
				$url
	));

    #my @html = split(/\n/,$html);
    return (
		video=>\%info,
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$title,
    );
}

return new MyPlace::URLRule::Rule::0_ddxzp_com;
1;

__END__

#       vim:filetype=perl


