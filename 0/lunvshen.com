#!/usr/bin/perl -w

#DOMAIN : lunvshen.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2016-01-09 01:26
#UPDATED: 2016-01-09 01:26
#TARGET : http://lunvshen.com/103308.html

use strict;
no warnings 'redefine';


=method1
sub apply_rule {
 return (
 #Set quick parsing method on
       '#use quick parse'=>1,

#Specify data mining method
       'data_exp'=>undef,
       'data_map'=>undef,

#Specify data mining method for nextlevel
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,

#Specify pages mining method
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

use MyPlace::URLRule::Utils qw/get_url/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
	my $id = $url;
	$id =~ s/[\?#].+$//;
	$id =~ s/.*\///;
	$id =~ s/\.[^\.]+$//;
	if(!$id) {
		$id = $url . "_";
	}
	else {
		$id = $id . "_";
	}
	my @imgs;	
	my $ext = ".jpg";
	while($html =~ m/<a[^>]+href='([^']+)'[^>]+data-thumb=''/g) {
		push @imgs,$1;
	}
	while($html =~ m/<img[^>]+class='detailpp'[^>]+src='([^']+)'/g) {
		push @imgs,$1;
	}
	if($html =~ m/<embed[^>]+src='([^']+)/) {
		push @imgs,$1;
		$ext = ".mp4";
	}
	foreach my $img(@imgs) {
		my $clean = $img;
		$clean =~ s/[\?#].+$//;
		$clean =~ s/\/+$//;
		my $name = $clean;
		if($clean =~ m/\/([^\/]+)\.([^\.]+)$/) {
			$name = $1;
			$ext = ".$2";
		}
		elsif($clean =~ m/\/([^\/]+)$/) {
			$name = $1;
		}
		$name =~ s/[\:\/\?\.\_\-\*]//g;
		push @data,$img . "\t" . $id . $name . $ext;
	}
    #my @html = split(/\n/,$html);
    return (
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
    );
}

=cut

1;

__END__

#       vim:filetype=perl


