#!/usr/bin/perl -w

# takes three params: 
#  - first is the filename
#  - second is what to look for, 
#  - third is what to replace it with

use strict;

if ((!$ARGV[0]) || (!$ARGV[1]) || (!$ARGV[2])) {
	print("usage: change-entry.pl <file> <look for> <replace with>\n");
	exit(1);
} 

my $file = $ARGV[0];
my $pattern = $ARGV[1];
my $replace = $ARGV[2];

if (!-f $file) {
	print("file '$file' does not exist.\n");
	exit(1);
}

open(OF, "<$file") or die "Unable to open $file : $!\n";
open(NF, ">$file.tmp") or die "Unable to open $file.tmp : $!\n";
foreach my $line (<OF>) {
	if ($line =~ /$pattern/) {
		$line =~ s/$pattern/$replace/g;
	}
	print NF $line;
}
close OF;
close NF;

if (unlink($ARGV[0])) {
	system('mv', "$ARGV[0].tmp", "$ARGV[0]");
} else {
	print "failed to unlink $ARGV[0] : $!\n";
}

