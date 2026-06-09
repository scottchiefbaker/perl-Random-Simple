#!/usr/bin/perl

use 5.006;
use strict;
use warnings;
use Test::More;
use Config;

# Skip if Perl wasn't built with ithreads support
if (!$Config{useithreads}) {
	plan skip_all => "Perl not built with ithreads support";
}

# threads can't be loaded until runtime when we know ithreads are available
require threads;

use Random::Simple;

###################################################################
###################################################################

# Spawn two threads. Each reads 5 rand() values and returns them.
# If the TLS fix is missing, both threads share the same `one` state
# and will produce correlated/identical sequences.

my $t1 = threads->create(sub {
	my @vals;
	for (1 .. 5) { push @vals, rand() }
	return \@vals;
});

my $t2 = threads->create(sub {
	my @vals;
	for (1 .. 5) { push @vals, rand() }
	return \@vals;
});

my $r1 = $t1->join();
my $r2 = $t2->join();

# Check all values are valid [0, 1)
foreach my $v (@$r1, @$r2) {
	ok($v >= 0 && $v < 1, "rand() in [0, 1): $v");
}

# Verify threads have independent generators (sequences differ)
my $same = 0;
for (my $i = 0; $i < 5; $i++) {
	$same++ if $r1->[$i] == $r2->[$i];
}
isnt($same, 5, "Threads generated different sequences");

done_testing();

# vim: tabstop=4 shiftwidth=4 noexpandtab autoindent softtabstop=4
