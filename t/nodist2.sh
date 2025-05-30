#! /bin/sh
# Copyright (C) 2001-2025 Free Software Foundation, Inc.
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

# Test to make sure nodist_noinst_HEADERS work.
# For PR 249.

. test-init.sh

cat >> configure.ac <<'EOF'
AC_OUTPUT
EOF

cat > Makefile.am << 'EOF'
nodist_noinst_HEADERS = baz.h
EOF

: > baz.h

$ACLOCAL
$AUTOCONF
$AUTOMAKE -a
./configure --prefix "$(pwd)/install"
$MAKE install-data

:
