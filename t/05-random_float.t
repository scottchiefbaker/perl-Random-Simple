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

###################################################################
###################################################################

# Statisically this should be right around 0.5
$num = get_avg_random_float($iterations);
ok($num > 0.45 && $num < 0.55, "random_float() gerenates the right size numbers") or diag("$num not between 0.45 and 0.55");

done_testing();

###################################################################
###################################################################

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
