#!/usr/bin/perl -w
#
# Namodn - namodn_apache_add.pl
#
# add's all apache entries for specified domain
#
# usage: namodn_apache_add.pl <fqdn>
#

use strict;

use Fcntl;
use POSIX;

# must be run as root
unless ($< == 0) { die "must be run as root.\n"; } 

my $www_dir = '/var/www/';
my $apache_conf = '/etc/apache/httpd.conf';
my $index_tmpl = 'apache_index.tmpl';
my $mksel_bin = 'namodn-mksel-www.sh';
my $fqdn = '';

if (! $ARGV[0]) {
	print "usage: namodn_apache_add.pl <FQDN>\n";
	exit 1;
} else {
	chomp @ARGV;
	$fqdn = $ARGV[0];
	$username = $ARGV[1];
}

########################################################################
# exim_aliases_dir
#
print "adding $fqdn in $exim_aliases_dir... ";
system('cp', $exim_alias_tmpl, "/tmp/$fqdn.aliases");

system('./change_entry.pl', "/tmp/$fqdn.aliases", 'TMPL_USERNAME', $username);

if ( -f "$exim_aliases_dir/$fqdn.aliases" ) {
	print "failed.\n$exim_aliases_dir/$fqdn.aliases already exists.\n";
	exit 1;
}

system('cp', "/tmp/$fqdn.aliases", $exim_aliases_dir);
print "done.\n";

my $curr_dir = `pwd`;
chdir($exim_aliases_dir);
system($rerun_alias_bin);
chdir($curr_dir);


########################################################################
# exim_conf
#
print "adding $fqdn entry to $exim_conf... ";

if (`grep $fqdn $exim_conf`) {
	print "failed.\nentry $fqdn, already exists in $exim_conf\n";
	exit 1;
}

my $tmpfile;
do {
    $tmpfile = tmpnam();
} until open(TMP, ">$tmpfile") or die "unable to open /tmp/$exim_conf for writing: $!\n";
open (CONF, "<$exim_conf") or die "unable to open $exim_conf for reading: $!\n";

foreach my $line (<CONF>) {
	if ($line =~ /^local_domains\s+=\s+/) {
		chomp $line;
		print TMP $line . ":$fqdn\n";
	} else {
		print TMP $line;
	}
}

close TMP;
close CONF;
system('cp', $exim_conf, "$exim_conf.bak");
system('cp', $tmpfile, $exim_conf);

print "done.\n";


########################################################################
# exim_passwd_account
#

print "generating /etc/passwd.$fqdn... ";

if ( -f "/etc/passwd.$fqdn" ) {
	print "failed.\nfile /etc/passwd.$fqdn already exists.\n";
	exit 1;
}

my $entry = `grep $username /etc/passwd`;
if (! $entry) {
	print "failed.\nusername $username does not exist in /etc/passwd.\n";
	exit 1;
}

open (FH, ">/etc/passwd.$fqdn") or die "unable to open /etc/passwd.$fqdn for writing: $!\n";
print FH $entry;
close FH;

print "done.\n";

exit 0;
