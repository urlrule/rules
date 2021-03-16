#!/usr/bin/perl -w
#DOMAIN : www.9797g.com
#AUTHOR : eotect <eotect@MYPLACE>
#CREATED: 2019-01-27 00:15
#UPDATED: 2019-01-27 00:15
#TARGET : http://www.9797g.com/video/?8601-0-0.html
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_www_9797g_com;
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
	my $html = get_url($url,'-v','charset:gbk');
    my @data;
	my %info;
	if($url =~ m/\/\?(\d+)/) {
		$info{id} = $1;
	}
	if($html =~ m/xTitle='([^']+)/) {
		$info{title} = $1;
		$info{title} =~ s/^(.*?)(\w{3,}-\d+)(.*?)$/$2_$1_$3/;
		$info{title} = create_title($info{title});
	}
	if($html =~ m/\$([^\$]+)\$/) {
		$info{video} = $1;
		if($info{video} =~ m/\.([^\.]+)$/) {
			$info{ext} = ".$1";
		}
	}
	if($info{video}) {
		$info{title} = $info{title} ? $info{id} . "_" . $info{title} : $info{id};
		$info{ext} = ".mp4" unless($info{ext});
		push @data,$info{video} . "\t$info{title}$info{ext}";
	}
	else {
		return (error=>"Error parsing page");
	}
    #my @html = split(/\n/,$html);
    return (
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
    );
}

return new MyPlace::URLRule::Rule::0_www_9797g_com;
1;

__END__

#       vim:filetype=perl


