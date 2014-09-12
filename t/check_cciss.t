#!/usr/bin/perl
BEGIN {
	(my $srcdir = $0) =~ s,/[^/]+$,/,;
	unshift @INC, $srcdir;
}

use strict;
use warnings;
use constant TESTS => 3;
use Test::More tests =>  TESTS * 5;
use test;

my @tests = (
	{
		status => OK,
		detect_hpsa => 'hpsa.refcnt',
		detect_cciss => 'no-file',
		version => 'cciss-1.09',
		controller => 'cciss_vol_status.zen',
		cciss_proc => '',
		smartctl => 'smartctl.cciss.$disk',
		message => '/dev/sda: (Smart Array P410i) RAID 1 Volume 0: OK',
	},
	{
		status => OK,
		detect_hpsa => 'no-such-file',
		detect_cciss => 'cciss',
		version => 'cciss-1.09',
		controller => 'cciss_vol_status.argos',
		cciss_proc => 'cciss/$controller',
		smartctl => 'smartctl.cciss.$disk',
		message => '/dev/cciss/c0d0: (Smart Array P400i) RAID 6 Volume 0: OK',
	},
	{
		status => OK,
		detect_hpsa => 'no-such-file',
		detect_cciss => 'cciss',
		version => 'cciss-1.11',
		controller => 'cciss/cciss_vol_status.cache-status',
		cciss_proc => 'cciss/$controller',
		smartctl => '',
		message => '/dev/cciss/c0d0: (Smart Array P400i) RAID 1 Volume 0: OK, Drives: 3NP3K2JG00009921RS5B,3NP3K40K00009920MTFH=OK, Cache: WriteCache ReadMem:104 MiB WriteMem:104 MiB',
	},
);

foreach my $test (@tests) {
	my $plugin = cciss->new(
		commands => {
			'detect hpsa' => ['<', TESTDIR . '/data/' .$test->{detect_hpsa} ],
			'detect cciss' => ['<', TESTDIR . '/data/' .$test->{detect_cciss} ],
			'controller status' => ['<', TESTDIR . '/data/' .$test->{controller} ],
			'controller status verbose' => ['<', TESTDIR . '/data/' .$test->{controller} ],
			'cciss_vol_status version' => ['<', TESTDIR . '/data/cciss/' .$test->{version} ],
			'cciss proc' => ['<', TESTDIR . '/data/' .$test->{cciss_proc} ],
			'smartctl' => ['<', TESTDIR . '/data/' .$test->{smartctl} ],
		},
		no_smartctl => 1,
	);
	ok($plugin, "plugin created");

	$plugin->check;
	ok(1, "check ran");

	ok(defined($plugin->status), "status code set");
	is($plugin->status, $test->{status}, "status code matches");
	is($plugin->message, $test->{message}, "status message");
}
