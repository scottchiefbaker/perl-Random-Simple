static uint32_t _rand32();
static uint64_t _rand64();

// Borrowed from https://www.pcg-random.org/posts/bounded-rands.html
static uint32_t _bounded_rand(uint32_t range) {
	uint32_t x = _rand32();
	uint64_t m = (uint64_t)x * (uint64_t)range;
	uint32_t l = (uint32_t)m;

	if (l < range) {
		uint32_t t = -range;
		if (t >= range) {
			t -= range;
			if (t >= range)
				t %= range;
		}
		while (l < t) {
			x = _rand32();
			m = (uint64_t)x * (uint64_t)range;
			l = (uint32_t)m;
		}
	}

	return m >> 32;
}

// https://prng.di.unimi.it/#remarks
static double _uint64_to_double(uint64_t num) {
	// A standard 64bit double floating-point number in IEEE floating point
	// format has 52 bits of significand. Thus, the representation can actually
	// store numbers with 53 significant binary digits.
	double scale = 1.0 / (1ULL << 53);  // 1 divided by 2^53
	double ret   = (num >> 11) * scale; // Top 53 bits divided by 1/2^53

	//printf("Double: %0.15f\n", ret);

	return ret;
}

// Use the C rand() function to return a 64 bit number
static uint64_t _crand64() {
	uint64_t high = rand();
	uint32_t low  = rand();
	uint64_t ret  = (high << 32) | low;

	return ret;
}

// MurmurHash3 Finalizer (Passes SmallCrush)
static uint64_t _hash_mur3(uint64_t x) {
    x ^= x >> 33;
    x *= 0xff51afd7ed558ccd;
    x ^= x >> 33;
    x *= 0xc4ceb9fe1a85ec53;
    x ^= x >> 33;
    return x;
}
