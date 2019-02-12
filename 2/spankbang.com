#!/usr/bin/perl -w
#DOMAIN : spankbang.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2019-01-29 23:49
#UPDATED: 2019-01-29 23:49
#TARGET : https://spankbang.com/3ts/pornstar/mona+wales 1
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_spankbang_com;
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
    my @pass_data;
    my @html = split(/\n/,$html);
	$url =~ s/%2b/+/g;
	my @urlinfo = url_getinfo($url);
	my $title = $urlinfo[2];
	$title =~ s/[-_\+\.]+/ /g;
	$title =~ s/\b(\w)/\U$1/g;
	my $last = 1;
	my $prev = "";
	my $suff = "";
	my @links;
	foreach(@html) {
		if(m/<p class="sry">(.+?)<\/p>/) {
			return (error=>$1);
		}
		while(m/<a[^>]+href="([^"]+)/g) {
			push @links,$1;
		}
	}
	foreach(@links) {
		next if(m/\/tags?\/\d+\/[^\/]*$/);
		if(m/^(.+\?page=)(\d+)(.*)$/) {
			if($last < $2) {
				$last = $2;
				$prev = $1;
				$suff = $3;
			}
		}
		elsif(m/^(.+\/)(\d+)(\/[^\/]*)$/g) {
			if($last < $2) {
				$last = $2;
				$prev = $1;
				$suff = $3;
			}
		}
	}
	if($last > 200 and $url =~ m/\/(?:tag|category)\//) {
		return ("error"=>"Too much page [$last] return, something maybe wrong");
	}
	#$last = 10 if($last >10);
	push @pass_data,$url;
	foreach(2 .. $last) {
		push @pass_data,url_getfull("$prev$_$suff",$url,@urlinfo);
	}
    return (
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
		#title=>$title,
    );
}

return new MyPlace::URLRule::Rule::2_spankbang_com;
1;

__END__

#       vim:filetype=perl


