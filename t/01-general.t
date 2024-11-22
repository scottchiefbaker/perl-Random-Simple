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

my $has_64bit = ($Config{uvsize} == 8);

my $min = 100;
my $max = 200;

my $iterations = 5000;

# If for some reason the automatic seeding does not work the first eight
# bytes will be zero. With a seed of (0,0) you can see this
#Random::Simple::seed(0,0); # Uncomment this to see the failure
my $bytes = random_bytes(10);
ok(substr($bytes, 0, 4) ne "\0\0\0\0", "First four bytes are not zero");

#my $str = sprintf('%v02X', $bytes);
#print "$str\n";

cmp_ok(get_avg_random_int($min, $max, $iterations), '<', $max + 1, "Less than max");
cmp_ok(get_avg_random_int($min, $max, $iterations), '>', $min - 1, "More than min");

cmp_ok(get_avg_random_int(2**8 , 2**32 -1, $iterations), '>', 2**8 - 1 , "More than 2^8");
cmp_ok(get_avg_random_int(2**16, 2**32 -1, $iterations), '>', 2**16 - 1, "More than 2^16");
cmp_ok(get_avg_random_int(2**24, 2**32 -1, $iterations), '>', 2**24 - 1, "More than 2^24");

cmp_ok(get_avg_random_int(0, 10, $iterations), '>', 4.5, "random_int() with a zero min works (more)");
cmp_ok(get_avg_random_int(0, 10, $iterations), '<', 5.5, "random_int() with a zero min works (less)");

is(length(random_bytes(16))   , 16  , "Generate 16 random bytes");
is(length(random_bytes(1))    , 1   , "Generate one random bytes");
is(length(random_bytes(0))    , 0   , "Generate zero random bytes");
is(length(random_bytes(-1))   , 0   , "Generate -1 random bytes");
is(length(random_bytes(49))   , 49  , "Generate 49 random bytes");
is(length(random_bytes(1024)) , 1024, "Generate 1024 random bytes");

# Build a list of a bunch of random numbers
my @nums;
for (my $i = 0; $i < $iterations; $i++) {
	push(@nums, random_int($min, $max));
}

# Check if ANY of the items are the mim/max
my $has_min = int(grep { $_ == $min } @nums);
my $has_max = int(grep { $_ == $max } @nums);

# Make sure we contain the lower and upper bounds (inclusive)
ok($has_min, "random_int() contains lower bound") or diag("$min not in sample");
ok($has_max, "random_int() contains upper bound") or diag("$max not in sample");

cmp_ok(get_avg_rand(undef, $iterations), ">", "0.45", "rand() range #1");
cmp_ok(get_avg_rand(undef, $iterations), "<", "0.55", "rand() range #2");

cmp_ok(get_avg_rand(1, $iterations), ">", "0.45", "rand(1) range #1");
cmp_ok(get_avg_rand(1, $iterations), "<", "0.55", "rand(1) range #2");

cmp_ok(get_avg_rand(10, $iterations), ">", "4.5", "rand(10) range #1");
cmp_ok(get_avg_rand(10, $iterations), "<", "5.5", "rand(10) range #2");

###################################################################
# Logic: generate a bunch of randoms and calculate the average
# to see if we fall in a logical threshold
###################################################################

# Average should be about 2**31
cmp_ok(get_avg_randX(32, $iterations), '>', 2**30, "rand32() generates the right size numbers");
cmp_ok(get_avg_randX(32, $iterations), '<', 2**32, "rand32() generates the right size numbers");

# Only do the 64bit tests on platforms that support it
if ($has_64bit) {
	# Average should be about 2**63
	cmp_ok(get_avg_randX(64, $iterations), '>', 2**62, "rand64() generates the right size numbers");
	cmp_ok(get_avg_randX(64, $iterations), '<', 2**64, "rand64() generates the right size numbers");
} else {
	diag("Skipping 64bit tests on 32bit platform");
}

###################################################################

# Statisically this should be right around 0.5
cmp_ok(get_avg_random_float($iterations), '>', 0.45, "random_float() generates the right size numbers");
cmp_ok(get_avg_random_float($iterations), '<', 0.55, "random_float() generates the right size numbers");

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

sub get_avg_random_int {
	my ($min, $max, $count) = @_;

	$count ||= 50000;

	my $total = 0;
	for (my $i = 0; $i < $count; $i++) {
		my $num = random_int($min, $max);

		$total += $num;
	}

	my $ret = $total / $count;
	#print "($min, $max) $num / $count = $ret\n";

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
