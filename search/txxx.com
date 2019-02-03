#!/usr/bin/perl -w
#DOMAIN : txxx.com
#AUTHOR : Eotect Nahn <eotect@myplace>
#CREATED: 2019-02-02 02:39
#UPDATED: 2019-02-02 02:39
#TARGET : ___TARGET___
#URLRULE: 2.0
package MyPlace::URLRule::Rule::search_txxxcom;
use base 'MyPlace::URLRule::Rule';
use strict;
use warnings;

=method1
sub apply_rule {
	my $self = shift;
	return $self->apply_quick(
	   'data_exp'=>undef,
	   'data_map'=>undef,
       'pass_exp'=>undef,
       'pass_map'=>undef,
       'pass_name_map'=>undef,
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

#use MyPlace::URLRule::Utils qw/get_url get_safename url_getname/;

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $query;
	if($url =~ m/^([\/]+):\/\/([^\/]+)\/(.+)$/) {
		$domain = $1;
		$query = $2;
	}
	else {
		$domain = "txxx.com";
		$query = $url;
	}

	my %maps = (
		'txxx'=>{
			domain=>'txxx.com',
			search=>['https://txxx.com/search/?s=###QUERY###',2,'+'],
			category=>['https://www.txxx.com/categories/###QUERY###/',2,'-'],
			name=>['https://txxx.com/models/###QUERY###/',2,'-'],
		},
		'spankbang'=>{
			domain=>'spankbang.com',
			search=>['https://spankbang.com/s/###QUERY###/',2,'+'],
			category=>['https://spankbang.com/category/###QUERY###/',2,'+'],
			tags=>['https://spankbang.com/tag/###QUERY###/',2,'+'],
		},
		'xhamster'=>{
			domain=>'xhamster.one',
			search=>['https://xhamster.one/search?q=###QUERY###',2,'+'],
			name=>['https://xhamster.one/pornstars/###QUERY###',2,'-'],
			category=>['https://xhamster.one/categories/###QUERY###',2,'-'],
			tags=>['https://xhamster.one/tags/###QUERY###',2,'-'],
		},
		'tubepornclassic'=>{
			domain=>'cn.tubepornclassic.com',
			category=>['https://xhamster.one/categories/###QUERY###',2,'-'],
			search=>['https://cn.tubepornclassic.com/search/###QUERY###',2,'%20'],
			name=>['https://cn.tubepornclassic.com/models/###QUERY###/',2,'-'],
		},
		'megatube'=>{
			domain=>'megatube.xxx',
			category=>['https://www.megatube.xxx/###QUERY###.porn',2,'-'],
			name=>['https://www.megatube.xxx/###QUERY###.pornstar',2,'-'],
			search=>['https://www.megatube.xxx/search/###QUERY###/',2,'-'],
		},
		'javmobile'=>{
			domain=>'javmobile.mobi',
			search=>['https://javmobile.mobi/videos/###QUERY###/',2,'-'],
			name=>['https://javmobile.mobi/videos/###QUERY###/',2,'-'],
		},

	);


    my @data;
    my @pass_data;
    #my @html = split(/\n/,$html);
    return (
        count=>scalar(@data),
        data=>\@data,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
        base=>$url,
        title=>$title,
    );
}

return new MyPlace::URLRule::Rule::search_txxxcom;
1;

__END__

#       vim:filetype=perl



