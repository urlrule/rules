#!/usr/bin/perl -w
#http://kimkardashian.celebuzz.com/2009/02/19/calendar_shoot/img_3196-jpg/
#Sat May 22 05:04:25 2010
use strict;
sub apply_rule {
return (
	'#use quick parse'=>1,
	data_exp=>'src\s*=\s*"(http:\/\/cdn\d+\.[^"]+?\/files\/[^"]+?)-\d+x\d+(\.[^."]+)"',
	data_map=>'$1 . $2',
	title_exp=>'\<link rel=\'up\' title=\'([^\']+)',
	title_map=>'$1',
	
);
}
1;
