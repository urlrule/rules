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

sub apply_rule {
	my $self = shift;
	$_[0] =~ s/ /%20/g;
	my $title = $_[0];
	if($title =~ m/[&\?]s=([^&]+)/) {
		$title = $1;
	}
	else {
		$title =~ s/^.*\/([^\/]+)\/[^\/]*$/$1/;
	}
	$title =~ s/%20/ /g;
	$title =~ s/%2[Bb]/+/g;
	$title =~ s/\d+$//;
	$title =~ s/[-_]+/ /g;
	$title =~ s/\b(\w)/\U$1/g;
	my $page_pre = $_[0];
	my $page_suf = "/";
	if($page_pre =~ m/^(.+)\/([^\/]+)$/) {
		$page_pre = "$1/";
		$page_suf = "/$2";
	}
	return $self->apply_quick(
	   'data_exp'=>undef,
	   'data_map'=>undef,
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,
       'pages_exp'=>'<a[^>]+data-query="page:(\d+)"',
       'pages_map'=>'$1',
       'pages_pre'=>"\"$page_pre\"",
       'pages_suf'=>"\"$page_suf\"",
       'pages_start'=>undef,
	   'pages_limit'=>undef,
	   'title'=>$title,
       'charset'=>undef
	);
}

=method2
use MyPlace::URLRule::Utils qw/get_url create_title/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
    #my @html = split(/\n/,$html);
    return (
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$title,
    );
}

=cut
return new MyPlace::URLRule::Rule::2_txxx_com;
1;

__END__

#       vim:filetype=perl


