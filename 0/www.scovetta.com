#!/usr/bin/perl -w

#DOMAIN : www.scovetta.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2015-12-10 23:37
#UPDATED: 2015-12-10 23:37
#TARGET : http://www.scovetta.com/archives/fehq/DOSUtils

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

use MyPlace::URLRule::Utils qw/get_url new_file_data unescape_text/;

sub apply_rule {
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my $title = undef;
    my @data;
    my @pass_data;
	my @pass_name;
=cvs method
	my @html = split(/\n/,$html);
	my $incvs = 0;
	foreach(@html) {
		if(m/^\s*-->/) {
			$incvs = 0;
			break;
		}
		elsif(m/^\s*<!-- BEGIN CSV OUTPUT FOR PARSING/) {
			$incvs = 1;
		}
		elsif($incvs) {
			my ($name,$url,$desc) = split(/,/,$_);
		}
	}
=cut
#=html method
	my @html = split(/<tr/,$html);
	my $nextpage = 0;
	foreach(@html) {
		if((!$nextpage) and m/<td[^>]+title="Next Page"[^>]*><a[^>]+href="([^"]+\/page-\d+)"/) {
			push @pass_data,$1;
			push @pass_name,"";
		}
		if(m/class="icon_column"><a href="([^"]+)"><img[^>]+\/icons\/([^\.]+)\..*<td class="description_[^>]+>([^<]+)/) {
			my $url = $1;
			my $desc = $3 ? unescape_text($3)  . "\n": '';
			my $type = $2;
			my $name = $url; 
			$name =~ s/.*\///;
			if($type eq 'folder') {
				push @pass_data,$url;
				push @pass_name,$name;
			}
			else {
				push @data,$url . "\t" . $name;
				push @data,new_file_data($name . ".txt",$desc) unless($name =~ m/(?:\.txt|\.htm|\.html|README)$/);
			}
		}
	}
#=cut
    #my @html = split(/\n/,$html);
    return (
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
		pass_name=>\@pass_name,
		samelevel=>1,
        base=>$url,
        title=>$title,
    );
}

=cut

1;

__END__

#       vim:filetype=perl


