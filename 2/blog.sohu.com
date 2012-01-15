#!/usr/bin/perl -w
#http://blog.sohu.com
#Mon Sep 13 23:53:58 2010



=method1
sub apply_rule {
 return (
       '#use quick parse'=>1,
       'data_exp'=>undef,
       'data_map'=>undef,
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pages_exp'=>undef,
       'pages_map'=>undef,
       'pages_pre'=>undef,
       'pages_suf'=>undef,
       'pages_start'=>undef,
       'charset'=>undef
 );
}
=cut

use MyPlace::HTTPGet;
#use MyPlace::HTML;
use strict;
sub _process {
    my ($url,$rule,$html) = @_;
    my $title = undef;
    my @data;
    my @pass_data;
    my $prefix;
    my $ebi;
    my $per = 20;
    my $count = 0;
	my @pass_name;
    my @html = split(/\n/,$html);
    foreach(@html) {
        if((!$prefix) and m/var\s*_blog_base_url\s*=\s*'([^']+)'/) {
            $prefix = $1;
        }
        elsif((!$ebi) and m/var\s*_ebi\s*=\s*'([^']+)'/) {
            $ebi = $1;
        }
        elsif((!$per) and m/var\s*itemPerPage\s*=\s*(\d+)/) {
            $per = $1;
        }
        elsif((!$count) and m/var\s*totalCount\s*=\s*(\d+)/) {
            $count = $1;
        }
    }
    if($ebi) {
        push @pass_data,$prefix . 'action/v_frag-ebi_' . $ebi . '/entry/';
		push @pass_name,'articles';
        my $page=1; 
        while($page*$per < $count) {
            $page++;
            push @pass_data,$prefix . 'action/v_frag-ebi_' . $ebi . '-pg_' . $page . '/entry/';
			push @pass_name,'articles';
        }
    }
	if($url =~ m/([^\.\/]+)\.blog\.sohu\.com/) {
#		@pass_data = ();
		push @pass_data, {
			url=>"http://pp.sohu.com/member/$1",
			level=>'3',
			title=>'albums',
		};
		push @pass_name,'albums',
	}
    return (
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
		pass_name=>\@pass_name,
        base=>$url,
        no_subdir=>1,
        work_dir=>$title,
    );
}

sub apply_rule {
    my $url = shift(@_);
    my $rule = shift(@_);
    my $http = MyPlace::HTTPGet->new();
    $url = $url . '/entry/' unless($url =~ m/entry\/$/);
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
#================================================================

#       vim:filetype=perl
1;
