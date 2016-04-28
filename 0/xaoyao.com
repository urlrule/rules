#!/usr/bin/perl -w

#DOMAIN : xaoyao.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2016-04-09 01:26
#UPDATED: 2016-04-09 01:26
#TARGET : http://xaoyao.com/thread-7010-1-1.html

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

use MyPlace::URLRule::Utils qw/get_url create_title/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v','charset:gbk');
    my $title = undef;
    my @data;
    my @pass_data;
	my @html = split(/\n/,$html);
	foreach(@html) {
		if((!$title) and m/<title>([^>]+)\s+-\s+[^-<]+<\/title>/) {
			$title = create_title($1);
		}
		elsif(m/href="(forum\.php\?mod=attachment[^"]+)[^>]+>(.+?)<\/a>/) {
			my $link = $1;
			my $ltitle = create_title($2);
			$link =~ s/&amp;/&/g;
			$link =~ s/%3D/=/g;
			if($link =~ m/aid=([^&]+).*&nothumb/) {
				$ltitle = "$1.jpg";
			}
			$ltitle =~ s/<[^>]+>//g;
			push @data,$link . ($ltitle ? "\t$ltitle" : "");
		}
	}
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


