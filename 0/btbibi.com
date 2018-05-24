#!/usr/bin/perl -w

#DOMAIN : btbibi.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2015-09-25 01:02
#UPDATED: 2015-09-25 01:02
#TARGET : http://btbibi.com/h/763dgvd9d181.html

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
	my $html = get_url($url,'-v');#,'charset:utf-8');
    my $title = undef;
    my @data;
    my @pass_data;
	my @html = split("<li",$html);
	foreach(@html) {
		my $t;
		my $h;
		if(m/\s+class="list-group-item">([^\r\n]+)/) {
			$t = $1;
			$t =~ s/<[^>]+>//g;
			$t =~ s/^\s+//;
			$t =~ s/\s+$//;
			$t =~ s/\[email&#160;protected\]@*//g;
			$t = create_title($t);
			if(m/href="magnet:.*btih:([^><"&]+)/) {
				$h = uc($1);
				push @data,"magnet:?xt=urn:btih:$h&dn=$t\t$t";
			}
		}
	}
	
    return (
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
    );
}

=cut

1;

__END__

#       vim:filetype=perl


