#!/usr/bin/perl -w
#DOMAIN : ddxzp.com
#AUTHOR : eotect <eotect@MYPLACE>
#CREATED: 2020-02-15 02:00
#UPDATED: 2020-02-15 02:00
#TARGET : http://ddxzp.com/video/category/free?pageNo=1&pageSize=60 1
#URLRULE: 2.0
package MyPlace::URLRule::Rule::1_ddxzp_com;
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

use MyPlace::WWW::Utils qw/get_url create_title_utf8 get_safename url_getname/;
my $AUTH = "Authorization:Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzaWQiOiI3Nzk3MzZhNy0zMDg2LTRhOTctYTMyOC0zZWM5ZTMxMzE4YWIiLCJqdGkiOiJjMTQ1NmY4MC02MWY3LTQwM2YtOGJhMy0wOGU3NmFiMjQ3NTkiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1lIjoidi11c2VyIiwibGFuZyI6ImNuIiwiYnJhbmRJZCI6IlNORiIsIlZpcnR1YWxVc2VyIjoiVHJ1ZSIsIlZJUFVzZXIiOiJGYWxzZSIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6Ikd1ZXN0IiwiZXhwIjoxNTgxNzA5Mjc1LCJpc3MiOiI0MTRlMTkyN2EzODg0ZjY4YWJjNzlmNzI4MzgzN2ZkMSIsImF1ZCI6InBob2VuaXhpbnRlcmFjdGl2ZSJ9.FmBleHoGje26dacmN3_CVhgBhZf138jZrFWqFaMV-10";

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $rurl = $url;
	#http://ddxzp.com/video/category/free?pageNo=1&pageSize=60
	#	=>
	#http://ddxzp.com/api/video/category/free?pageNo=1&pageSize=60&size=800x538
	$rurl =~ s/\/video\//\/api\/video\//;
	my $base = $url;
	$base =~ s/\/video\/.*/\/video\//;
	my $html = get_url($rurl,'-v',"--referer",$url,'-H',$AUTH);
    my $title = undef;
    my @data;
    my @pass_data;
    my @html = split(/\},\{/,$html);
	my %info;
	foreach(@html) {
		my %v;
		foreach my $k(qw/cid name/) {
			if(m/"$k"\s*:\s*"([^"]+)/) {
				$v{$k} = $1;
			}
		}
		$info{$v{cid}} = create_title_utf8($v{name}) if($v{cid} and $v{name});
	}
	foreach(keys %info) {
		push @data,"urlrule:" . $base . $_ . "\t" . $info{$_} . ".ts";
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

return new MyPlace::URLRule::Rule::1_ddxzp_com;
1;

__END__

#       vim:filetype=perl


