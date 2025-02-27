#! /bin/sh
# Copyright (C) 1999-2025 Free Software Foundation, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Test to make sure several *-local's in a single rule work.

. test-init.sh

targets='all install-exec install-data uninstall'
echo "$targets:" | sed -e 's/[ :]/-local&/g' > Makefile.am
cat Makefile.am # For debugging.

$ACLOCAL
$AUTOMAKE

for target in $targets; do
  grep "${target}-local" Makefile.in # For debugging.
  
  # This grep fails, thus the test is listed in XFAIL.
  # We're checking that (e.g.) all-am does not depend on all-local,
  # but why?
  grep "${target}-am:.*${target}-local" Makefile.in
done

:
