#!/usr/bin/perl -w
#http://kimkardashian.celebuzz.com/photos/page/5/
#Sat May 22 05:31:57 2010

sub apply_rule {
return (
	'#use quick parse'=>1,
	pass_exp=>'\<h2 class="posttitle"\>\<a href="([^"]+)"',
#	pass_exp=>'class="gallery-count"\>\<a href="([^"]+)',
	pass_map=>'$1',
);
}
1;
__END__

