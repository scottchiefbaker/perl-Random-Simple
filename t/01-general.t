#!/usr/bin/perl

use 5.006;
use strict;
use warnings;
use Test::More;
use Random::Simple;
use Config;
use Time::HiRes qw(sleep);

########################################################
# Testing random numbers is hard so we do basic sanity #
# checking of the bounds                               #
########################################################

# Check if the UV (unsigned value) Perl type is 64bit
my $has_64bit = ($Config{uvsize} == 8);

my $min = 100;
my $max = 200;
my $num = 0; # placeholder for re-usable var

# Number of iterations to use for our average testing
my $iterations = 10000;

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
sleep(0.03); # Sleep a tiny bit here so the tests output in order

###################################################################################
###################################################################################

$bytes = Random::Simple::_get_os_random_bytes(8); # C API
$ok    = ok(substr($bytes, 0, 4) ne "\0\0\0\0", "First four OS bytes are NOT zero");
$ok    = ok(substr($bytes, 4, 4) ne "\0\0\0\0", "Second four OS bytes are NOT zero");

#########################################################################
#########################################################################

# Test to make sure we're making the RIGHT number of random bytes
is(length(random_bytes(16))   , 16  , "Generate 16 random bytes");
is(length(random_bytes(1))    , 1   , "Generate one random bytes");
is(length(random_bytes(0))    , 0   , "Generate zero random bytes");
is(length(random_bytes(-1))   , 0   , "Generate -1 random bytes");
is(length(random_bytes(49))   , 49  , "Generate 49 random bytes");
is(length(random_bytes(1024)) , 1024, "Generate 1024 random bytes");

# rand() test
$num = get_avg_rand(undef, $iterations);
ok($num > 0.45 && $num < 0.55, "rand()") or diag("$num not between 0.45 and 0.55");

# rand(1) test which should be the same as rand()
$num = get_avg_rand(1, $iterations);
ok($num > 0.45 && $num < 0.55, "rand(1)") or diag("$num not between 0.45 and 0.55");

# rand(10) test
$num = get_avg_rand(10, $iterations);
ok($num > 4.5 && $num < 5.5, "rand(10)") or diag("$num not between 4.5 and 5.5");;

###################################################################
###################################################################

# _rand32() average should be about 2**31
$num = get_avg_randX(32, $iterations);
ok($num > 2**30 && $num < 2**32, "rand32() generates the right size numbers") or diag("rand32(): $num not in range");

# Only do the 64bit tests on platforms that support it
if ($has_64bit) {
	# _rand64() average should be about 2**63
	$num = get_avg_randX(64, $iterations);
	ok($num > 2**62 && $num < 2**64, "rand64() generates the right size numbers") or diag("rand664(): $num not in range");
} else {
	diag("Skipping 64bit tests on 32bit platform");
}

###################################################################

# Statisically this should be right around 0.5
$num = get_avg_random_float($iterations);
ok($num > 0.45 && $num < 0.55, "random_float() gerenates the right size numbers") or diag("$num not between 0.45 and 0.55");

###################################################################

done_testing();

###################################################################
###################################################################

sub get_avg_randX {
	my ($bits, $count) = @_;

	$count ||= 50000;

	my $total = 0;
	for (my $i = 0; $i < $count; $i++) {
		my $num;
		if ($bits == 32) {
			$num = Random::Simple::_rand32();
		} elsif ($bits == 64) {
			$num = Random::Simple::_rand64();
		} else {
			$num = 0; # bees?
		}

		$total += $num;
	}

	my $ret = $total / $count;

	return $ret;
}

sub get_avg_random_float {
	my ($count) = @_;

	$count ||= 50000;

	my $total = 0;
	for (my $i = 0; $i < $count; $i++) {
		my $num = random_float();

		$total += $num;
	}

	my $ret = $total / $count;
	#print "FF: $total / $count = $ret\n";

	return $ret;
}

sub get_avg_rand {
	my ($one, $count) = @_;

	$count ||= 50000;

	my $total = 0;
	for (my $i = 0; $i < $count; $i++) {
		my $num;
		if (defined $one) {
			$num = rand($one);
		} else {
			$num = rand();
		}

		$total += $num;
	}

	my $ret = $total / $count;
	#print "($min, $max) $num / $count = $ret\n";

	return $ret;
}

sub perl_rand64 {
	my $high = int(rand() * 2**32 - 1);
	my $low  = int(rand() * 2**32 - 1);

	my $ret = ($high << 32) | $low;

	return $ret;
}
