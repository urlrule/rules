#!/usr/bin/perl -w

#DOMAIN : photo.weibo.com
#AUTHOR : Eotect Nahn <eotect@myplace>
#CREATED: 2016-04-08 00:38
#UPDATED: 2016-04-08 00:38
#TARGET : ___TARGET___

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

use MyPlace::Weibo::Photo qw/get_albums get_url/;

sub apply_rule {
    my ($url,$rule) = @_;
	my %info;
	foreach(qw/uid page count/) {
		if($url =~ m/[\?&]$_=([^&]+)/) {
			$info{$_} = $1;
		}
	}
	my($st,@ph) = get_albums($info{uid},$info{page},$info{count});
	if(!$st) {
		return (error=>join(" ",@ph),info=>\%info);
	}
    my @pass_data;
	foreach(@ph) {
		push @pass_data,
			'http://photo.weibo.com/' . 
			 $info{uid} . '/albums/detail/album_id/' . 
			 $_->{album_id} . '#!/mode/1/page/1';
	}
    return (
		#	albums=>\@ph,
        count=>0,
        pass_data=>\@pass_data,
        pass_count=>scalar(@pass_data),
        base=>$url,
    );
}

=cut

1;

__END__

#       vim:filetype=perl



