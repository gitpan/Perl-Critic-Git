#!perl

# Note: cannot use -T here, Git::Repository uses environment variables directly.

use strict;
use warnings;

use Perl::Critic::Git;
use Test::Deep;
use Test::Exception;
use Test::Git;
use Test::More;


# Check there is a git binary available, or skip all.
has_git();
plan( tests => 6 );

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

# Tests retrieving authors.
my $authors;
lives_ok(
	sub
	{
		$authors = $git_critic->get_authors();
	},
	'Retrieve authors.',
);
isa_ok(
	$authors,
	'ARRAY',
	'$authors',
);
cmp_bag(
	$authors,
	[
		'author1@example.com',
		'author2@example.com',
	],
	'The list of authors is correct.'
);
