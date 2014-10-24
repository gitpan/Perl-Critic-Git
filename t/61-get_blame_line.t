#!perl

# Note: cannot use -T here, Git::Repository uses environment variables directly.

use strict;
use warnings;

use Data::Dumper;
use Perl::Critic::Git;
use Test::Exception;
use Test::Git;
use Test::More;
use Test::NoWarnings qw();


# Check there is a git binary available, or skip all.
has_git();
plan( tests => 8 );

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

# Tests retrieving git blame lines.
my $blame_lines;
lives_ok(
	sub
	{
		$blame_lines = $git_critic->get_blame_lines();
	},
	'Retrieve git blame lines.',
);
isa_ok(
	$blame_lines,
	'ARRAY',
	'$blame_lines',
);
is(
	scalar( @$blame_lines ),
	11,
	'Find 11 lines with corresponding blame information.',
);

# Test retrieving the lines individually.
subtest(
	'Retrieve blame lines individually.',
	sub
	{
		plan( tests => 11 * 2 );
		for ( my $i = 1; $i <= scalar( @$blame_lines ); $i++ )
		{
			my $blame_line;
			lives_ok(
				sub
				{
					$blame_line = $git_critic->get_blame_line( $i );
				},
				"Retrieve line $i.",
			);
			
			is(
				$blame_line,
				$blame_lines->[ $i - 1 ],
				"Retrieved line matches row from blame_lines().",
			);
		}
	}
);

Test::NoWarnings::had_no_warnings();
