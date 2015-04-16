#!/usr/bin/perl -w

#DOMAIN : www.bttiantang.com
#AUTHOR : xiaoranzzz <xiaoranzzz@MyPlace>
#CREATED: 2015-04-17 01:25
#UPDATED: 2015-04-17 01:25
#TARGET : http://www.bttiantang.com/subject/20650.html

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
	my @torrent;
	while($html =~ m/<a[^>]+href="\/download.php\?([^"]+)"[^>]+title="([^"]+)BT种子下载"/g) {
		my %info = split(/[&=]/,$1);
		my $name = $2;

		delete $info{n};
		delete $info{temp};
		$info{action} = 'download';
		my @form = map {"$_=$info{$_}"} (keys %info);
		$info{post} = 'post://www.bttiantang.com/download.php?' . join("&",@form);

		if($name =~ m/^【([^】]+)】\s*([^\/]+)\s*(.*)\.(\d\d\d\d)\.([\.\d]+(?:TB|GB|MB|KB))$/) {
			my @ns = ($2,$3,$4,$1,$5);
			if($ns[0]) {
				$ns[0] =~ s/^\s*\/?\s*//;
				$ns[0] =~ s/\s*\/?\s*$//;
				$title = $ns[0];
			}
			if($ns[1]) {
				$ns[1] =~ s/^\s*\/?\s*//;
				$ns[1] =~ s/\s*\/?\s*$//;
				if($ns[0] and ($ns[1] eq $ns[0])) {
					$ns[1] = "";
				}
			}
			$ns[3] =~ s/^.*?(\d+[pP]).*$/\L$1/ if($ns[3]);
			$name = join("_",@ns);
		}
		$name =~ s/\s*[:_\/\"\'\\\?\|\*]+\s*/_/g;
		$name .= "_" . uc($info{uhash}) if($info{uhash});
		$info{name} = $name;
		push @torrent,\%info;
		push @data,$info{post} . "\t" . $info{name} . ".torrent";
	}
    return (
		info=>\@torrent,
        count=>scalar(@data),
        data=>\@data,
        pass_count=>0,
        base=>$url,
        title=>$title,
    );
}

=cut

1;

__END__

#       vim:filetype=perl


