#!/usr/bin/perl -w
use strict;
use Encode qw/find_encoding/;
use Cwd qw/getcwd/;
use File::Spec::Functions qw/catfile/;
use Getopt::Long;
use MyPlace::URLRule::SaveById;


my $DEFAULT_HOST = "default";
my $DB_EXT = ".DB";
my $ID_EXT = ".ID";
my $ENCODING = "utf8";
binmode STDOUT,$ENCODING;
binmode STDERR,$ENCODING;
my @OPTIONS = qw/
		help|h
		manual|man
		list|l
		debug|d
		hosts|sites:s
		command|c:s
		/;
my %OPTS;
GetOptions(\%OPTS,@OPTIONS);
my $WD = getcwd();
my $utf8 = find_encoding($ENCODING);

my @NAMES;
if(@ARGV) {
	foreach(@ARGV){
		push @NAMES,$utf8->decode($_);
	}
}
my $COMMAND = $OPTS{list} ? 'LIST' : $OPTS{command} ? uc($OPTS{command}) : 'UPDATE';

sub process_command {
	my $cmd = shift;
	my $handler = shift;
	my $query = shift;
	if($cmd eq 'LIST') {
		my $idx = 1;
		foreach(keys %{$query->{target}}) {
			printf "\t[%03d] %-20s\t%s\n",$idx,$_,$query->{target}->{$_};
			$idx++;
		}
		return 0;
	}
	elsif($cmd eq '_UPGRADE') {
		return 1 unless($query->{target});
		$handler->_upgrade($query,$WD);
		return 0;
	}
	elsif($cmd eq 'UPDATE') {
		return 1 unless($query->{target});
		$handler->update($query,$WD);
		return 0;
	}
}

sub process_host {
	my $HOST = shift;
	my @names = @_;
	my $HOSTNAME = uc($HOST);
	my $host_db = catfile($WD,"${HOSTNAME}${DB_EXT}");
	my $id_db = catfile($WD,"${HOSTNAME}${ID_EXT}");
	if(!@names) {
		open FI,'<:utf8',$id_db or die("Error opening $id_db:$!\n");
		while(<FI>) {
			chomp;
			next if(m/^#/);
			if(m/^\s*([^\s]+)/) {
				push @names,$1;
			}
		}
		close FI;
	}
	
	my $proc = MyPlace::URLRule::SaveById->new("host"=>$HOST);
	$proc->{DEBUG} = $OPTS{debug};
	$proc->feed($host_db);
	my $query = $proc->query(@names);
	return process_command($COMMAND,$proc,$query);
}

my @HOSTS = ($DEFAULT_HOST);
if($OPTS{hosts}) {
	@HOSTS = split(/\s*,\s*/,$OPTS{hosts});
}

my $exitval = 0;
foreach(@HOSTS) {
	print STDERR "Host: $_ \tCommand: $COMMAND\n";
	my $r = process_host($_,@NAMES);
	if($r != 0) {
		$exitval = $r;
	}
}
exit $exitval;

__END__

#       vim:filetype=perl
