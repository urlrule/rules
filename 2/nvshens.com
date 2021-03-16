#!/usr/bin/perl -w
#DOMAIN : www.nvshens.com
#AUTHOR : eotect <eotect@MyPlace>
#CREATED: 2018-08-31 03:39
#UPDATED: 2018-08-31 03:39
#TARGET : https://www.nvshens.com/girl/16293/ 2
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_www_nvshens_com;
use MyPlace::URLRule::Utils qw/get_url extract_title/;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

=method1
sub apply_rule {
	my $self = shift;
	return $self->apply_quick(
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
	   'pages_limit'=>undef,
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
	);
}
=cut


sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
	my %info = (
		host=>'nvshens.com',
	);
	if($html =~ m/<title>([^-]+)/) {
		$info{uname} = $1;
	}
	if($url =~ m/^(https?:\/\/)([^\/]+)\/(.*?)([^\/]+)\/(\d+)\//) {
		$info{profile} = "$4/$5";
		$title = "$4_$5";
		$info{host} = $2;
		push @pass_data,"$1$2/$3$4/$5/"; 
		push @pass_data,"$1$2/$3$4/$5/album/"; 
		$info{host} =~ s/^www\.//;
	}
	my $ld = $rule->{level_desc};
	if($ld && ($ld eq 'info')) {
		return %info;
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

return new MyPlace::URLRule::Rule::2_www_nvshens_com;
1;

__END__

#       vim:filetype=perl


