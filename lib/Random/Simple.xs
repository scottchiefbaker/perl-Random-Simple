#define PERL_NO_GET_CONTEXT  // we'll define thread context if necessary (faster)
#include "EXTERN.h"          // globals/constant import locations
#include "perl.h"            // Perl symbols, structures and constants definition
#include "XSUB.h"            // xsubpp functions and macros
#include <stdlib.h>          // rand()
#include <stdint.h>          // uint64_t
#include "random_os_bytes.h" // for _get_os_rand64()

#include "pcg.h"

// Alernate PRNGs available
//#include "xorshiro.h"
//#include "xoroshiro128starstar.h"
//#include "splitmix64.h"
//
// Other PRGNs just need three functions _seed(S1,S2), _rand32(),
// and _rand64()

#include "rand-common.h"

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

MODULE = Random::Simple  PACKAGE = Random::Simple
PROTOTYPES: ENABLE

 # XS code goes here

 # XS comments begin with " #" to avoid them being interpreted as pre-processor
 # directives

U32 _rand32()

UV _rand64()

UV _get_os_rand64()

void _seed(UV seed1, UV seed2)

U32 _bounded_rand(UV range)

const char * _get_os_random_bytes(U16 num)
	// Read random bytes from OS level PRNG
	// Either: /dev/random or BCryptGenRandom on Windows
	CODE:
		// We build a small buffer and fill it with bytes
		char buf[num + 1];
		int bytes = _get_os_random_bytes(buf, num);

		// Return a null string on error
		if (bytes != num) { buf[0] = 0; }

		RETVAL = buf;

	OUTPUT:
		RETVAL
