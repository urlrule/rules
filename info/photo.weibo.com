#!/usr/bin/perl -w

#DOMAIN : photo.weibo.com
#AUTHOR : Eotect Nahn <eotect@myplace>
#CREATED: 2016-04-08 00:02
#UPDATED: 2016-04-08 00:02
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

use MyPlace::Weibo::Photo qw/get_photos get_url/;

sub apply_rule {
    my ($url,$rule) = @_;

	my %user = (id=>0);
	my @pass_data;
	my $title;

	if($url =~ m/\/(\d+)\//) {
		$user{id} = $1;
	}
	$url = 'http://photo.weibo.com/' . $user{id} . '/albums/index' if($user{id});
	my $html = get_url($url,'-v');
	if($url =~ m/weibo\.com\/(\d+)/) {
		$user{id} = $1;
	}
	elsif($url =~ m/weibo\.com\/u\/(\d+)/) {
		$user{id} = $1;
	}
	elsif($url =~ m/weibo\.com\/([^\/\?]+)[^\/]*$/) {
		$user{user} = $1;
	}
	if($html =~ m/<div class="page_error">(.+?)<\/div/s) {
		my $err = $1;
		$err =~ s/<[^>]+>//sg;
		$err =~ s/[\s\t\r\n]+//sg;
		return (
			error=>$err,
		);
	}
	if((!$user{id}) and $html =~ m/\$CONFIG\['oid'\]='(\d+)'/) {
		$user{id} = $1;
	}
	if($html =~ m/\$CONFIG\['onick'\]='([^']+)'/) {
		$user{name} = $1;
	}
	if((!$user{uname}) and $html =~ m/<title>(.+)的专辑\s+/) {
		$user{name} = $1;
	}
	foreach(qw/id albums photos name/) {
		next if($user{$_});
		if($html =~ m/"$_":\s*(\d+)/) {
			$user{$_} = $1;
		}
	}
	if(!$user{id}) {
		return (error=>'Invalid URL',user=>\%user);
	}

    return (
		user=>\%user,
		profile=>$user{id},
		uid=>$user{id},
		host=>'photo.weibo.com',
		uname=>$user{name},
    );
}

=cut

1;

__END__

#       vim:filetype=perl



