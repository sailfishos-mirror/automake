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

package Automake::Item;

use 5.006; use strict; use warnings;

use Carp;

use Automake::ChannelDefs;
use Automake::DisjConditions;

=head1 NAME

Automake::Item - base class for Automake::Variable and Automake::Rule

=head1 DESCRIPTION

=head2 Methods

=over 4

=item C<new Automake::Item $name>

Create and return an empty Item called C<$name>.

=cut

sub new ($$)
{
  my ($class, $name) = @_;
  my $self = {
    name => $name,
    defs => {},
    conds => {},
  };
  bless $self, $class;
  return $self;
}

=item C<$item-E<gt>name>

Return the name of C<$item>.

=cut

sub name ($)
{
  my ($self) = @_;
  return $self->{'name'};
}

=item C<$item-E<gt>def ($cond)>

Return the definition for this item in condition C<$cond>, if it
exists.  Return 0 otherwise.

=cut

sub def ($$)
{
  # This method is called very often, so keep it small and fast.  We
  # don't mind the extra undefined items introduced by lookup failure;
  # avoiding this with 'exists' means doing two hash lookup on
  # success, and proved worse on benchmark.
  my $def = $_[0]->{'defs'}{$_[1]};
  return defined $def && $def;
}

=item C<$item-E<gt>rdef ($cond)>

Return the definition for this item in condition C<$cond>.  Abort with
an internal error if the item was not defined under this condition.

The I<r> in front of C<def> stands for I<required>.  One
should call C<rdef> to assert the conditional definition's existence.

=cut

sub rdef ($$)
{
  my ($self, $cond) = @_;
  my $d = $self->def ($cond);
  prog_error ("undefined condition '" . $cond->human . "' for '"
	      . $self->name . "'\n" . $self->dump)
    unless $d;
  return $d;
}

=item C<$item-E<gt>set ($cond, $def)>

Add a new definition to an existing item.

=cut

sub set ($$$)
{
  my ($self, $cond, $def) = @_;
  $self->{'defs'}{$cond} = $def;
  $self->{'conds'}{$cond} = $cond;
}

=item C<$var-E<gt>conditions>

Return an L<Automake::DisjConditions> describing the conditions
that an item is defined in.

These are all the conditions for which it would be safe to call
C<rdef>.

=cut

sub conditions ($)
{
  my ($self) = @_;
  prog_error ("self is not a reference")
    unless ref $self;
  return new Automake::DisjConditions (values %{$self->{'conds'}});
}

=item C<@missing_conds = $var-E<gt>not_always_defined_in_cond ($cond)>

Check whether C<$var> is always defined for condition C<$cond>.
Return a list of conditions where the definition is missing.

For instance, given

  if COND1
    if COND2
      A = foo
      D = d1
    else
      A = bar
      D = d2
    endif
  else
    D = d3
  endif
  if COND3
    A = baz
    B = mumble
  endif
  C = mumble

we should have (we display result as conditional strings in this
illustration, but we really return DisjConditions objects):

  var ('A')->not_always_defined_in_cond ('COND1_TRUE COND2_TRUE')
    => ()
  var ('A')->not_always_defined_in_cond ('COND1_TRUE')
    => ()
  var ('A')->not_always_defined_in_cond ('TRUE')
    => ("COND1_FALSE COND3_FALSE")
  var ('B')->not_always_defined_in_cond ('COND1_TRUE')
    => ("COND1_TRUE COND3_FALSE")
  var ('C')->not_always_defined_in_cond ('COND1_TRUE')
    => ()
  var ('D')->not_always_defined_in_cond ('TRUE')
    => ()
  var ('Z')->not_always_defined_in_cond ('TRUE')
    => ("TRUE")

=cut

sub not_always_defined_in_cond ($$)
{
  my ($self, $cond) = @_;

  # Compute the subconditions where $var isn't defined.
  return
    $self->conditions
      ->sub_conditions ($cond)
	->invert
	  ->multiply ($cond);
}


1;
