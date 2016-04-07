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
	$html =~ s/var \$CONFIG = \$GLOBAL_INFO//s;
	$html =~ s/account_data.*$//s;
	if($html =~ m/<title>(.+)的专辑\s+/) {
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

	if(!$user{albums}) {
		return (error=>'No albums exists for user',user=>\%user);
	}
	my $pages = $user{albums} / 5;
	$pages++ if($user{albums} % 5);
	
	foreach(1 .. $pages) {
		push @pass_data,'http://photo.weibo.com/albums/get_all?' .
				join("&",
					"uid=$user{id}",
					"count=5",
					"page=$_",
					"type=1",
					"__rnd=" . time . '794'
				)
		;
	}
    return (
		user=>\%user,
        count=>0,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$user{id},
    );
}

=cut

1;

__END__

#       vim:filetype=perl



