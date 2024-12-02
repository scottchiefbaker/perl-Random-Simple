use 5.008005;
use ExtUtils::MakeMaker 7.12; # for XSMULTI option

WriteMakefile(
	NAME             => 'Random::Simple',
	VERSION_FROM     => 'lib/Random/Simple.pm',
	ABSTRACT_FROM    => 'lib/Random/Simple.pm',
	AUTHOR           => 'Scott Baker',
	XSMULTI          => 1,
	AUTHOR           => 'Scott Baker <bakerscot@cpan.org>',
	LICENSE          => 'mit',
	MIN_PERL_VERSION => '5.012',
	META_MERGE       => { dynamic_config => 1 },

	PREREQ_PM => {
		'ExtUtils::MakeMaker' => '7.12',
		$^O eq 'MSWin32' ? ('Win32::API' => 0) : (),
	},
	CONFIGURE_REQUIRES => {
		'ExtUtils::MakeMaker' => '7.12',
	},
	TEST_REQUIRES => {
		'Test::More' => '0',
	},

	META_MERGE => {
		'meta-spec' => { version => 2 },
		resources => {
			repository => {
				url => 'https://github.com/scottchiefbaker/perl-Random-Simple.git',
				web => 'https://github.com/scottchiefbaker/perl-Random-Simple',
				type => 'git'
			},
			bugtracker => {
				"web" => "https://github.com/scottchiefbaker/perl-Random-Simple/issues"
			},
		}
	},
);
