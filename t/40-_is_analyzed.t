#!perl

# Note: cannot use -T here, Git::Repository uses environment variables directly.

use strict;
use warnings;

use Perl::Critic::Git;
use Test::Exception;
use Test::Git;
use Test::More tests => 6;

# Retrieve the path to the test git repository.
ok(
	open( my $persistent, '<', 't/test_information' ),
	'Retrieve the persistent test information.',
) || diag( "Error: $!" );
ok(
	defined( my $work_tree = <$persistent> ),
	'Retrieve the path to the test git repository.',
);

# Prepare Perl::Critic::Git.
my $git_critic;
lives_ok(
	sub
	{
		$git_critic = Perl::Critic::Git->new(
			file   => $work_tree . '/test.pl',
			level  => 'harsh',
		);
	},
	'Create a Perl::Critic::Git object.',
);

ok(
	!$git_critic->_is_analyzed(),
	'The file is flagged as not analyzed.',
);

lives_ok(
	sub
	{
		$git_critic->get_authors();
	},
	'Get authors, which requires analyzing the file.',
);

ok(
	$git_critic->_is_analyzed(),
	'The file is flagged as analyzed.',
);