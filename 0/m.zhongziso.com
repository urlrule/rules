#!/usr/bin/perl -w
#DOMAIN : m.zhongziso.com
#UPDATED: 2018-05-28 03:08
#TARGET : https://m.zhongziso.com/search/%E5%8F%8B%20%E6%AF%8D/
#URLRULE: 2.0
package MyPlace::URLRule::Rule::0_m_zhongziso_com;
use MyPlace::URLRule::Utils qw/get_url create_title/;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;


sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $html = get_url($url,'-v');
    my @data;
    my @html = split(/<ul[^>]+class="list-group"/,$html);
	foreach(@html) {
		my %i;
		next unless(m/<a[^>]+class="text-success"[^>]*>(.+?)<\/a>/);
		$i{title} = $1;
        $i{title} =~ s/<[^>]*>//g;
		$i{title} =~ s/\s*\[email&#160;protected\]@?\s*//g;
		$i{title} = create_title($i{title});
		$i{title} =~ s/\s*\[email&#160;protected\]@?\s*//g;
		next unless(m/<a[^>]+href="(magnet:[^"]+)"/);
		$i{magnet} = $1;
		$i{magnet} =~ s/&amp;/&/g;
		$i{magnet} =~ s/xt=urn:btih:([^&]+)/xt=urn:btih:\U$1/;
		$i{hash} = uc($1);
		if($i{magnet} !~ m/&dn=/) {
			$i{magnet} .= '&dn=' . $i{title};
		}
		push @data,"$i{magnet}\t$i{title}";
	}
	
    return (
        count=>scalar(@data),
        data=>\@data,
        base=>$url,
    );
}

return new MyPlace::URLRule::Rule::0_m_zhongziso_com;
1;

__END__

#       vim:filetype=perl


