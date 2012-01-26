#!/usr/bin/perl -w
#http://aaronhane.blog.163.com
#Fri Jan 27 00:56:12 2012
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

#use MyPlace::URLRule::Utils qw/get_url/;

use MyPlace::163::Blog;
sub apply_rule {
    my ($url,$rule) = @_;

	if(!$rule->{level}) {
		my $album = MyPlace::163::Blog->extract_images($url);
		return (
			title=>$album->{title},
			data=>$album->{images},
		) if($album);
		return undef;
	}

	my $p163 = new MyPlace::163::Blog;
	if($rule->{level} == '1' || $rule->{level} == '2') {
		my $blogs;
		if($url =~ m/\?user=([^&]+)&id=([^&]+)/) {
			$blogs = $p163->get_blogs($2,$1);
		}
		else {
			$p163->init($url);
			$blogs = $p163->get_blogs;
		}
		return (
			level=>0,
			pass_data=>$blogs,
		);
	}
	if($rule->{level} >= '3') {
		$p163->init($url);
		my @pass_name;
		my @pass_data;
		my($user,$id,$albumId) = (
			$p163->name,
			$p163->id,
			$p163->albumId,
		);
		if($albumId) {
			push @pass_data,"http://photo.163.com/$albumId";
			push @pass_name,"photos";
		}
		if($user) {
			push @pass_data,"http://blog.163.com/?user=$user&id=$id" if($user);
			push @pass_name,"blogs";
		}
		return (
			pass_count=>scalar(@pass_data),
	        pass_data=>\@pass_data,
			pass_name=>\@pass_name,
	    );
	};
}
1;
=cut

1;

__END__

#       vim:filetype=perl
