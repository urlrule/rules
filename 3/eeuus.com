use MyPlace::URLRule::Utils qw/get_url/;

sub apply_rule {
	my $url = shift;
	return (
		'url'=>$url,
		'base'=>$url,
		'pass_data'=>[qw'
			/cn/index31.htm
			/cn/index32.htm
			/cn/index33.htm
			/cn/index34.htm
			/cn/index37.htm
		'],
	);
}

#       vim:filetype=perl
