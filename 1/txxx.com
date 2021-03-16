#!/usr/bin/perl -w
#DOMAIN : txxx.com
#AUTHOR : eotect <eotect@MYPLACE>
#CREATED: 2019-01-28 03:03
#UPDATED: 2019-01-28 03:03
#TARGET : https://www.txxx.com/categories/milf/ 1
#URLRULE: 2.0
package MyPlace::URLRule::Rule::1_txxx_com;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;
=method1
sub apply_rule {
	my $self = shift;
	if($_[0] =~ m/\/videos\//) {
		return (
			count=>1,
			data=>['urlrule:' . $_[0]],
		);
	}
	my $base = $_[0];
	$base =~ s/^([^\/]+\/\/[^\/]+).*$/$1/;
	return $self->apply_quick(
       'data_exp'=>'href="[^"]*\/videos\/([^"]+)"',
       'data_map'=>"\"urlrule:$base/videos/\$1\"",
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
use MyPlace::URLRule::Utils qw/get_url create_title url_getinfo/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
    #my @html = split(/\n/,$html);
	if($html =~ m/<div class="page-error">([^<]+)/) {
		return (error=>$1);
	}
	my $base = $url;
	$base =~ s/^([^\/]+\/\/[^\/]+).*$/$1/;
	my %dups;
    while($html =~ m/href="[^"]*\/videos\/([^"]+)"/g) {
		my $id = $1;
		$id =~ s/\?utm_source=search$//;
		next if($dups{$id});
		$dups{$id} = 1;
		push @data,"urlrule:$base/videos/$id";
	}
    return (
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
    );
}

return new MyPlace::URLRule::Rule::1_txxx_com;
1;

__END__

#       vim:filetype=perl


