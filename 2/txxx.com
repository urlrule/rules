#!/usr/bin/perl -w
#DOMAIN : txxx.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2019-01-28 20:45
#UPDATED: 2019-01-28 20:45
#TARGET : https://www.txxx.com/search/?s=blonde 2
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_txxx_com;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;
=method1
sub apply_rule {
	my $self = shift;
#	$_[0] =~ s/ /%20/g;
#	my $title = $_[0];
#	if($title =~ m/[&\?]s=([^&]+)/) {
#		$title = $1;
#	}
#	else {
#		$title =~ s/^.*\/([^\/]+)\/[^\/]*$/$1/;
#	}
#	$title =~ s/%20/ /g;
#	$title =~ s/%2[Bb]/+/g;
#	$title =~ s/\d+$//;
#	$title =~ s/[-_\+]+/ /g;
#	$title =~ s/\b(\w)/\U$1/g;
	return $self->apply_quick(
	   'data_exp'=>undef,
	   'data_map'=>undef,
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,
       'pages_exp'=>'href="([^"]*?\/)(\d+)(\/[^"]*)"[^>]+(?:data-action="ajax"|title="Page\s+)',
       'pages_map'=>'$2',
       'pages_pre'=>'$1',
       'pages_suf'=>'$3',
       'pages_start'=>undef,
	   'pages_limit'=>undef,
	   'pages_error'=>200,
	   'title'=>undef,
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
	if($html =~ m/<div class="message message--no-content">([^>]+)/) {
		return (error=>$1);
	}
	my($pre,$suf,$last) = ("","",0);
	while($html =~ m/href="([^"]*?\/)(\d+)(\/[^"]*)"[^>]+(?:data-action="ajax"|title="Page\s+)/g) {
		if($2>$last) {
			$last = $2;
			$pre = $1;
			$suf = $3;
		}
	}
	push @pass_data,$url;
	if($last>1) {
		foreach(2 .. $last) {
			push @pass_data,"$pre$_$suf";
		}
	}
    #my @html = split(/\n/,$html);
    return (
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
    );
}

return new MyPlace::URLRule::Rule::2_txxx_com;
1;

__END__

#       vim:filetype=perl


