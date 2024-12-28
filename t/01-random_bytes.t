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

# Number of iterations to use for our average testing
my $iterations = 10000;

#########################################################################
#########################################################################

# Test to make sure we're making the RIGHT number of random bytes
is(length(random_bytes(16))   , 16  , "Generate 16 random bytes");
is(length(random_bytes(1))    , 1   , "Generate one random bytes");
is(length(random_bytes(0))    , 0   , "Generate zero random bytes");
is(length(random_bytes(-1))   , 0   , "Generate -1 random bytes");
is(length(random_bytes(49))   , 49  , "Generate 49 random bytes");
is(length(random_bytes(1024)) , 1024, "Generate 1024 random bytes");

###################################################################
###################################################################

done_testing();
