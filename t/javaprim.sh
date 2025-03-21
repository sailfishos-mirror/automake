#! /bin/sh
# Copyright (C) 1998-2025 Free Software Foundation, Inc.
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

# Test to make sure JAVA variable can be defined by AC_SUBST.

. test-init.sh

cat >> configure.ac << 'END'
AC_SUBST([JAVA])
END

cat > Makefile.am << 'END'
javadir = $(datadir)/java
java_JAVA = a.java b.java c.java
END

$ACLOCAL
$AUTOMAKE

grep -i java Makefile.in # For debugging.
grep '^JAVA = *@JAVA@ *$' Makefile.in

:
