#!/usr/bin/perl -w
#http://thai-pix.com/tgp/Thai-porn-stars/Natt-HC-10a/index5.html
#Fri Nov 21 03:18:16 2014
use strict;
no warnings 'redefine';


=method1
sub apply_rule {
 return (
       '#use quick parse'=>1,
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
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
 );
}
=cut

use MyPlace::URLRule::Utils qw/get_url/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
	if($url =~ m/\/tgp\//) {
		while($html =~ m/<a href="([^"]+\.(?:jpg|wmv|avi|mpg))/g) {
			push @data,$1;
		}
		if($html =~ m/span class="style13">([^<]+)</) {
			$title = $1;
		}
	}
	elsif($url =~ m/thumbnails\.php/) {
		while($html =~ m/<img src="(albums\/[^"]+\/)tn_([^"]+)[^>]+alt="([^"]+)/g) {
			my $pre = $1;
			my $image = $2;
			my $filename = $3;
			if($filename !~ m/\.jpg$/) {
				push @data,"$pre$filename";
			}
			else {
				push @data,"$pre$image";
			}
		}
		#	if($html =~ m/<h2>([^<]+)/) {
		#	$title = $1;
		#}
	}
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

1;

__END__

#       vim:filetype=perl
