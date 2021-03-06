#!/usr/bin/perl -w

#DOMAIN : meipai.com
#AUTHOR : eotect <eotect@myplace>
#CREATED: 2015-02-14 02:47
#UPDATED: 2015-02-14 02:47

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
    my @pass_data;
	my %info;
    my @html = split(/\n/,$html);
	foreach(@html) {
		if(!$info{username}) {
			$info{username} = $1 if(m/<title>(.+?)的美拍/);
		}
		if(!$info{uid}) {
			if(m/href="\/user\/(\d+)"[^>]+class="user-l-t1 dbl current"/) {
				$info{uid} = $1;
			}
			elsif(m/data-type="user"[^>]+data-shareId="(\d+)"/) {
				$info{uid} = $1;
			}
			elsif(m/user_id: '(\d+)'/) {
				$info{uid} = $1;
			}
		}
		if(!$info{videos}) {
			if(m/<span class="user-txt pa">(\d+)</) {
				$info{videos} = $1;
			}
		}
	}
	if(!$info{uid}) {
		return (
			error=>"Faield to parse page: $url",
			info=>\%info,
		);
	}
	$info{videos} ||= 0;
	my $SIZE = 12;
	my $PAGES = int($info{videos} / 12);
	$PAGES += 1 if($info{videos} % 12);
	for my $p (1 .. $PAGES) {
		push @pass_data,
			"http://www.meipai.com/users/user_timeline?page=$p&count=$SIZE&single_column=1&uid=$info{uid}";
#			"http://www.meipai.com/users/user_timeline?page=$p&count=$SIZE&tid=$info{uid}&category=0";
	}
#	return (
#		error=>"Code needs updating for level 0",
#	);
    return (
		info=>\%info,
		uid=>$info{uid},
		uname=>$info{username},
		profile=>$info{uid},
		host=>'meipai.com',
		url=>'http://www.meipai.com/user/' . $info{uid},
        count=>0,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$info{uid},
    );
}

=cut

1;

__END__

#       vim:filetype=perl



