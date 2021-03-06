#!/usr/bin/perl -w
#http://www.babelistings.com/cgi-bin/atx/out.cgi?s=100&c=1&l=sid:256;iid:30;gid:3507641;kwid:11518;pos:1&u=http://www.sunnyleone.com/gal/new/pictures/13/index.php?nats=ODQ6Mzox
#Mon Dec 19 02:19:18 2011
use strict;
use MyPlace::Curl;
use URI;

sub apply_rule {
    my $url = shift(@_);
    my $rule = shift(@_);
	if($url =~ m/^http:\/\/fake\.href\.img\/(.+)$/) {
		$url = $1;
		my $test = MyPlace::URLRule::parse_rule(
				$url,
				$rule->{level},
				$rule->{action},
				@{$rule->{args}},
		);
		if(-f $test->{source}) {
#			print STDERR "Redirect to $url\n";
			return (
				count=>0,
				pass_data=>[$url],
				level=>$test->{level},
				action=>$test->{action},
			);
		}
	}
    my $http = MyPlace::Curl->new();
    my (undef,$html) = $http->get($url);
	if(length($html) < 1000 and $html =~ m/window\.location\s*=\s*'([^']+)'/) {
		my $new_url = $1;
		print STDERR "Redirect to $new_url\n";
		return (count=>0,pass_data=>[$new_url],base=>$url,no_subdir=>1,same_level=>1);
	}
	else {
		my $base= $url;
		my %data;
		if($base =~ m/&u=(.+)$/) {
			$base = $1;
		}
		elsif($base =~ m/link\.php\?(.+)$/){
			$base = $1;
		}
		if(!($base eq $url)) {
			open FI,'-|',qw/curl --progress-bar -I/,$base;
			while(<FI>) {
				if(m/^Location:\s*(.+)$/) {
					$base = $1;
					last;
				}
			}
			close FI;
			print STDERR ("Location changed to $base\n") unless($base eq $url);
		}
		while($html =~ m/href=(["'])([^'"]+\.(:?jpg|mpg|wmv|rmvb|mpeg|jpeg|png|gif))\1/g) {
			$data{$2}=1;
		}
		my @data = keys %data;
		return (
			count=>scalar(@data),
			base=>$base,
			data=>\@data,
			no_subdir=>1
		);
	}
}
=cut

1;

__END__

#================================================================
# apply_rule will be called with ($RuleBase,%Rule),the result returned have these meaning:
# $result{base}          : Base url to build the full url
# $result{work_dir}      : Working directory (will be created if not exists)
# $result{data}          : Data array extracted from url,will be passed to $result{action}(see followed)
# $result{action}        : Command which the $result{data} will be piped to,can be overrided
# $result{pipeto}        : Same as action,Command which the $result{data} will be piped to,can be overrided
# $result{hook}          : Hook action,function process_data will be called
# $result{no_subdir}     : Do not create sub directories
# $result{pass_data}     : Data array which will be passed to next level of urlrule
# $result{pass_name}     : Names of each $result{pass_data}
# $result{pass_arg}      : Additional arguments to be passed to next level of urlrule
# urlrule_quick_parse($url,$rule,$data_exp,$data_map,$pass_exp,$pass_map,$charset)
# urlrule_parse_data($url,$rule,$data_exp,$data_map,$charset)
# urlrule_parse_pass_data($url,$rule,$pass_exp,$pass_map,$charset)
# 
# $result{same_level}    : Keep same rule level for passing down
# $result{level}         : Specify rule level for passing down
#================================================================

#       vim:filetype=perl
1;
