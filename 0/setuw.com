#!/usr/bin/perl -w
#DOMAIN : setuw.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MYPLACE>
#CREATED: 2019-06-18 02:15
#UPDATED: 2019-06-18 02:15
#TARGET : http://setuw.com/tu/4/20ksx_tuigirl36.html
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_setuw_com;
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

use MyPlace::URLRule::Utils qw/get_url get_safename strnum/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
    #my @html = split(/\n/,$html);
	my $idx = 0;
	while($html =~ m/'se'\s*:\s*'([^']+)'/g) {
		$idx++;
		my $url = $1;
		my $ext = ".jpg";
		if($url =~ m/\.([^\.]+)$/) {
			$ext = ".$1";
		}
		push @data,$url . "\t" . strnum($idx,3) . $ext;
	}
	if($html =~ m/<title>([^<]+)/) {
		$title = get_safename($1);
		$title =~ s/_[^_]+$//g;
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

return new MyPlace::URLRule::Rule::0_setuw_com;
1;

__END__

#       vim:filetype=perl


