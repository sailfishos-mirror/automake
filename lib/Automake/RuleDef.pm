# Copyright (C) 2003-2025 Free Software Foundation, Inc.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

package Automake::RuleDef;

use 5.006; use strict; use warnings;
use Carp;
use Exporter;

use Automake::ChannelDefs;
use Automake::ItemDef;

our @ISA = qw (Automake::ItemDef Exporter);
our @EXPORT = qw (&RULE_AUTOMAKE &RULE_USER);

=head1 NAME

Automake::RuleDef - a class for rule definitions

=head1 SYNOPSIS

  use Automake::RuleDef;
  use Automake::Location;

=head1 DESCRIPTION

This class gathers data related to one Makefile-rule definition.
It shouldn't be needed outside of F<Rule.pm>.

=head2 Constants

=over 4

=item C<RULE_AUTOMAKE>, C<RULE_USER>

Possible owners for rules.

=cut

use constant RULE_AUTOMAKE => 0; # Rule defined by Automake.
use constant RULE_USER => 1;     # Rule defined in the user's Makefile.am.

=back

=head2 Methods

=over 4

=item C<new Automake::RuleDef ($name, $comment, $location, $owner, $source)>

Create a new rule definition with target C<$name>, with associated comment
C<$comment>, Location C<$location> and owner C<$owner>, defined in file
C<$source>.

=cut

sub new ($$$$$)
{
  my ($class, $name, $comment, $location, $owner, $source) = @_;

  my $self = Automake::ItemDef::new ($class, $comment, $location, $owner);
  $self->{'source'} = $source;
  $self->{'name'} = $name;
  return $self;
}

=item C<$source = $rule-E<gt>source>

Return the source of the rule.

=cut

sub source ($)
{
  my ($self) = @_;
  return $self->{'source'};
}

=item C<$name = $rule-E<gt>name>

Return the name of the rule.

=cut

sub name ($)
{
  my ($self) = @_;
  return $self->{'name'};
}

=back

=head1 SEE ALSO

L<Automake::Rule>, L<Automake::ItemDef>.

=cut

1;
