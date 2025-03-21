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

##################################################################
# The master copy of this file is in Automake's source repository.
# Please send updates to automake-patches@gnu.org.
##################################################################

package Automake::Configure_ac;

use 5.006; use strict; use warnings;

use Exporter;

use Automake::ChannelDefs;
use Automake::Channels;

our @ISA = qw (Exporter);
our @EXPORT = qw (&find_configure_ac &require_configure_ac);

=head1 NAME

Automake::Configure_ac - Locate configure.ac or configure.in.

=head1 SYNOPSIS

  use Automake::Configure_ac;

  # Try to locate configure.in or configure.ac in the current
  # directory.  It may be absent.  Complain if both files exist.
  my $file_name = find_configure_ac;

  # Likewise, but bomb out if the file does not exist.
  my $file_name = require_configure_ac;

  # Likewise, but in $dir.
  my $file_name = find_configure_ac ($dir);
  my $file_name = require_configure_ac ($dir);

=over 4

=back

=head2 Functions

=over 4

=item C<$configure_ac = find_configure_ac ([$directory])>

Find a F<configure.ac> or F<configure.in> file in C<$directory>,
defaulting to the current directory.  Complain if both files are present.
Return the name of the file found, or the former if neither is present.

=cut

sub find_configure_ac (;@)
{
  my ($directory) = @_;
  $directory ||= '.';
  my $configure_ac =
    File::Spec->canonpath (File::Spec->catfile ($directory, 'configure.ac'));
  my $configure_in =
    File::Spec->canonpath (File::Spec->catfile ($directory, 'configure.in'));

  if (-f $configure_in)
    {
      msg ('obsolete', "autoconf input should be named 'configure.ac'," .
                       " not 'configure.in'");
      if (-f $configure_ac)
	{
	  msg ('unsupported',
	       "'$configure_ac' and '$configure_in' both present.\n"
	       . "proceeding with '$configure_ac'");
          return $configure_ac
	}
      else
        {
          return $configure_in;
        }
    }
  return $configure_ac;
}


=item C<$configure_ac = require_configure_ac ([$directory])>

Like C<find_configure_ac>, but fail if neither is present.

=cut

sub require_configure_ac (;$)
{
  my $res = find_configure_ac (@_);
  fatal "'configure.ac' is required" unless -f $res;
  return $res
}

1;
