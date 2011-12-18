#!/usr/bin/perl -w
#http://www.babelistings.com/cgi-bin/atx/out.cgi?s=100&c=1&l=sid:256;iid:30;gid:3507641;kwid:11518;pos:1&u=http://www.sunnyleone.com/gal/new/pictures/13/index.php?nats=ODQ6Mzox
#Mon Dec 19 02:19:18 2011
use strict;



sub apply_rule {
 return (
       '#use quick parse'=>1,
       'data_exp'=>'href="([^"]+\.(:?jpg|mpg|wmv|rmvb|mpeg|jpeg|png|gif))"',
       'data_map'=>
<<'CODES',
{
	my $rel = $1;
	if(!$LOCAL_VAR{url_moved}) {
		my $base= $url;
		if($base =~ m/&u=([^=]+)/) {
			$base = $1;
		}
		open FI,'-|',qw/curl --progress-bar -I/,$base;
		while(<FI>) {
			if(m/^Location:\s*(.+)$/) {
				$base = $1;
				app_warning("\nLocation changed to $base\n");
				last;
			}
		}
		close FI;
		$LOCAL_VAR{url_moved} = $base;
	}
	return build_url($LOCAL_VAR{url_moved},$rel)->as_string;
}
CODES
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,
       'pages_exp'=>undef,
       'pages_map'=>undef,
       'pages_pre'=>undef,
       'pages_suf'=>undef,
       'pages_start'=>undef,
       'title_exp'=>undef,
       'title_map'=>undef,
       'charset'=>undef
 );
}

=method2
use MyPlace::Curl;
#use MyPlace::HTML;

sub _process {
    my ($url,$rule,$html) = @_;
    my $title = undef;
    my @data;
    my @pass_data;
    #my @html = split(/\n/,$html);
    return (
        count=>scalar(@data),
        data=>[@data],
        pass_count=>scalar(@pass_data),
        pass_data=>[@pass_data],
        base=>$url,
        no_subdir=>1,
        work_dir=>$title,
    );
}

sub apply_rule {
    my $url = shift(@_);
    my $rule = shift(@_);
    my $http = MyPlace::Curl->new();
    my (undef,$html) = $http->get($url);
    return &_process($url,$rule,$html,@_);
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
