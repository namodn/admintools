#!/usr/bin/perl -w
#
# Namodn - namodn_bind_add.pl
#
# add domain name entry to bind files and named.conf
#
# usage: namodn_bind_add.pl <FQDN>
#

use strict;

# must be run as root
unless ($< == 0) { die "must be run as root.\n"; } 

my $bind_dir = '/var/cache/bind/';
my $named_conf = '/etc/bind/named.conf';

my $bind_tmpl = 'bind_domain.tmpl';
my $fqdn = '';
my $serial = `date +%Y%M%d%H%M`;
chomp $serial;


if (! $ARGV[0]) {
	print "usage: namodn_bind_add.pl <FQDN>\n";
	exit 1;
} else {
	$fqdn = $ARGV[0];
	chomp $fqdn;
}

########################################################################
# bind_dir
#
print "adding $fqdn in $bind_dir... ";
system('cp', $bind_tmpl, "/tmp/$fqdn");

system('./change_entry.pl', "/tmp/$fqdn", 'TMPL_DOMAIN', $fqdn);
system('./change_entry.pl', "/tmp/$fqdn", 'TMPL_SERIAL', $serial);

if ( -f "$bind_dir/$fqdn" ) {
	print "failed.\n$bind_dir/$fqdn already exists.\n";
	exit 1;
}

system('cp', "/tmp/$fqdn", $bind_dir);
print "done.\n";

########################################################################
# named_conf
#
print "adding $fqdn entry to $named_conf... ";

if (`grep $fqdn $named_conf`) {
	print "failed.\nentry $fqdn, already exists in $named_conf\n";
	exit 1;
}
open(CONF, ">>$named_conf") or die "unable to open $named_conf for appending.\n";
print CONF "zone \"$fqdn\" {\n";
print CONF "\ttype master;\n";
print CONF "\tfile \"$fqdn\";\n";
print CONF "\tnotify yes;\n";
print CONF "};\n";
close CONF;

print "done.\n";

print "don't forget to restart your nameserver.\n";

exit 0;
