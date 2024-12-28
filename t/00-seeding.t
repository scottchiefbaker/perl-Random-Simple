#!/usr/bin/perl

use 5.006;
use strict;
use warnings;
use Test::More;
use Random::Simple;
use Config;

########################################################
# Testing random numbers is hard so we do basic sanity #
# checking of the bounds                               #
########################################################

# If for some reason the automatic seeding does not work the first eight
# bytes will be zero. With a seed of (0,0) you can see this
#Random::Simple::seed(0,0); # Uncomment this to see the failure
my $bytes = random_bytes(10);
my $ok    = ok(substr($bytes, 0, 4) ne "\0\0\0\0", "First four random bytes are NOT zero");
my $ok2   = ok(substr($bytes, 4, 4) ne "\0\0\0\0", "Second four random bytes are NOT zero");

if (!$ok || !$ok2) {
	my $str = sprintf('%v02X', $bytes);
	diag("First ten bytes: $str");
}

# Use a specific random seed so we can output it via diag for testing later
my $seed1 = perl_rand64();
my $seed2 = perl_rand64();

# If we want to recreate tests we can set the seeds manually here:
#$seed1 = 127;
#$seed2 = 489;
Random::Simple::seed($seed1,$seed2);
diag("Random Seeds: $seed1 / $seed2");

done_testing();

###################################################################
###################################################################

sub perl_rand64 {
	my $high = int(rand() * 2**32 - 1);
	my $low  = int(rand() * 2**32 - 1);

	my $ret = ($high << 32) | $low;

	return $ret;
}
