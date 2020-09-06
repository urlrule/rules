#!/usr/bin/perl -w
#DOMAIN : fi11.com
#AUTHOR : Eotect Nahn <eotect@myplace>
#CREATED: 2020-02-24 02:24
#UPDATED: 2020-02-24 02:24
#TARGET : ___TARGET___
#URLRULE: 2.0
package MyPlace::URLRule::Rule::2_fi11_com;
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

sub apply_rule {
	my $self = shift;
    my ($url,$rule) = @_;
	my $opts = $rule->{options} ? $rule->{options} : {};
    my @pass_data;
	my @pass_name;
	my $base = $url;
	$base =~ s/\/[^\/]+$//;
	my %defs = (
		"G点视频"=>"$base/albumvideo.aspx?AlbumID=7&Name=G%E7%82%B9%E8%A7%86%E9%A2%91",
		"熟女少妇"=>"$base/albumvideo.aspx?AlbumID=9&Name=%E7%86%9F%E5%A5%B3%E5%B0%91%E5%A6%87",
		"精选AV"=>"$base/albumvideo.aspx?AlbumID=1&Name=%E7%B2%BE%E9%80%89AV",
		"swag台湾精推"=>"$base/albumvideo.aspx?AlbumID=10&Name=swag%E5%8F%B0%E6%B9%BE%E7%B2%BE%E6%8E%A8",
		"泄露门事件"=>"$base/albumvideo.aspx?AlbumID=2&Name=%E6%B3%84%E9%9C%B2%E9%97%A8%E4%BA%8B%E4%BB%B6",
		"萝莉学生"=>"$base/albumvideo.aspx?AlbumID=4&Name=%E8%90%9D%E8%8E%89%E5%AD%A6%E7%94%9F",
		"网红约拍私拍"=>"$base/albumvideo.aspx?AlbumID=5&Name=%E7%BD%91%E7%BA%A2%E7%BA%A6%E6%8B%8D%E7%A7%81%E6%8B%8D",
		"国产"=>"$base/tag.aspx?type=4",
		"主播"=>"$base/tag.aspx?type=11",
		"日韩"=>"$base/tag.aspx?type=17",
		"欧美"=>"$base/tag.aspx?type=23",
		"动漫"=>"$base/tag.aspx?type=29",
	);
	foreach(keys %defs){
		push @pass_data,$defs{$_};
		push @pass_name,$_;
	}
    #my @html = split(/\n/,$html);
    return (
        base=>$url,
        pass_count=>scalar(@pass_data),
        pass_data=>\@pass_data,
		pass_name=>\@pass_name,
        title=>undef,
    );
}

return new MyPlace::URLRule::Rule::2_fi11_com;
1;

__END__

#       vim:filetype=perl



