#!/usr/bin/perl -w
#DOMAIN : ps5566.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2020-03-31 03:08
#UPDATED: 2020-03-31 03:08
#TARGET : http://ps5566.com/a/ym/6760.html
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_ps5566_com;
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

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
	my $html = get_url($url,'-v');
    my @data;
    my @pass_data;
    my @html = split(/\n/,$html);
	my %info;
	foreach(@html) {
		if(!$info{title} and m/<meta name="description" content="([^"]+)"/) {
			$info{title} = $1;
		}
		#elsif(!$info{prefix} and m/HOME<\/a>\s*>\s*<a[^>]+>([^<]+)<\/a>/) {
		#	$info{prefix} = "$1";
		#}
		elsif(!$info{image} and m/<img[^>]+src="(http[^"]+)"/) {
			$info{image} = $1;
		}
		elsif(!$info{torrent} and m/<br>\[BT.*(http:[^>]+\.torrent)/) {
			$info{torrent} = $1;
		}
		last if($info{title} and $info{image} and $info{torrent});
	}
	if($info{title}) {
		$info{title} = get_safename($info{title});
		push @data,$info{image} . "\t$info{title}.jpg" if($info{image});
		push @data,$info{torrent} . "\t$info{title}.torrent" if($info{torrent});
	}
	else {
		push @data,$info{image} if($info{image});
		push @data,$info{torrent} if($info{torrent});
	}
	my $title = "#$info{prefix}" if($info{prefix});
    return (
		#info=>\%info,
        base=>$url,
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        title=>$title,
    );
}

return new MyPlace::URLRule::Rule::0_ps5566_com;
1;

__END__

#       vim:filetype=perl


