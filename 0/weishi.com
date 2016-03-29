#!/usr/bin/perl -w
#http://www.weishi.com/t/2003061038631146?pgv_ref=weishi.sync.weibo&pgv_uid=6020984
#Sun Mar  8 00:27:33 2015
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
       何旋君君'pass_exp'=>undef,
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

#http://www.weishi.com/t/2003061038631146?pgv_ref=weishi.sync.weibo&pgv_uid=6020984
sub apply_rule {
    my ($url,$rule) = @_;
	if($url !~ m/downloadVideo\.php/) {
		return (download=>[$url],data=>[$url],count=>1);
	}

	my $vhtml = get_url($url,'-v');
	my @data;
	while($vhtml =~ m/"(http:[^"]+)"/g) {
		my $video = $1;
		$video =~ s/\\//g;
		push @data,$video;
	}
    return (
        count=>scalar(@data),
        data=>\@data,
		download=>\@data,
        base=>$url,
    );
}


1;

__END__

#       vim:filetype=perl
