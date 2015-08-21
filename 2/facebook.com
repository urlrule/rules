#!/usr/bin/perl -w
#https://www.facebook.com/Alina.fans
#Thu May 24 01:22:09 2012
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

sub apply_rule {
    my ($url,$rule) = @_;
#	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
	my $pass_url = $url;
	if($url =~ m/profile\.php\?id=(\d+)/) {
		$title = $1;
		$pass_url = $url . "&sk=photos" unless($url =~ m/&sk=photos/);
	}
	elsif($url =~ m/^(https?):\/\/(w*\.?facebook\.com)\/([^\/]+)\/?/) {
		$title = $3;
		$pass_url = "$1://$2/$3/photos/";
	}
	@pass_data = ($pass_url);
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
