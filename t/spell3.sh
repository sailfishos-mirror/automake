#! /bin/sh
# Copyright (C) 1996-2025 Free Software Foundation, Inc.
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

# Test to make sure some internal _DEPENDENCIES variables don't cause
# errors.

. test-init.sh

cat > Makefile.am << 'END'
TAGS_DEPENDENCIES = joe
## Required to avoid error.
ETAGS_ARGS = joe
END

$ACLOCAL
$AUTOMAKE

:
