#!/usr/bin/perl -w

#DOMAIN : meipai.com
#AUTHOR : eotect <eotect@myplace>
#CREATED: 2015-02-14 02:30
#UPDATED: 2015-02-14 02:30

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
use JSON qw/decode_json/;

sub apply_rule {
	use Encode qw/find_encoding/;
	my $utf8 = find_encoding('utf8');
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
	my $json = eval('decode_json($html)');
    my $title = undef;
    my @data;
    my @pass_data;
	my $info;
	if($json && $json->{medias}) {
		my $one;
		foreach(@{$json->{medias}}) {
			push @pass_data,$_->{url};
			$one = $_ unless($one);
		}
		if($one) {
			$info->{uid} = $one->{user}->{id};
			$info->{username} = $utf8->encode($one->{user}->{screen_name});
			$info->{user} = $one->{user}->{url};
		}
	}
    #my @html = split(/\n/,$html);
    return (
		info=>$info,
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



