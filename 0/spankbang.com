#!/usr/bin/perl -w
#DOMAIN : spankbang.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2019-01-29 18:31
#UPDATED: 2019-01-29 18:31
#TARGET : https://spankbang.com/2xcl7/video/chanel+preston+the+mistress
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_spankbang_com;
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

use MyPlace::URLRule::Utils qw/get_url create_title url_getinfo url_getfull url_getname/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
	my %info;
	my @html = split(/\n/,$html);
	my($base,$path,$name) = url_getinfo($url);
	$info{filename} = $name;
	foreach(@html) {
		if(m/<source[^>]+src="([^"]+)/) {
			$info{video} = $1;
		}
		if(m/<video[^>]+poster="([^"]+)/) {
			$info{image} = $1;
		}
		last if($info{video} and $info{image});
	}
	return (error=>"Error parsing page") unless($info{video});
		foreach($info{video},$info{image}) {
			s/&amp;/&/g;
			my $src = $_;
			$src = url_getfull($src,$url,$base,$path);
			my $ext = url_getname($src);
			if($ext =~ m/^[^\/]+\.[^\.\/\?]+$/) {
				$ext = "_$ext";
			}
			else {
				$ext = ".mp4";
			}
			push @data,$src . "\t" . $info{filename} . $ext;
		}
    return (
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
        title=>$title,
    );
}

return new MyPlace::URLRule::Rule::0_spankbang_com;
1;

__END__

#       vim:filetype=perl


