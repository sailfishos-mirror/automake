#! /bin/sh
# Copyright (C) 2010-2025 Free Software Foundation, Inc.
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

# Test for regressions in computation of names of .Plo files for
# automatic dependency tracking.
# Keep this in sync with sister test 'depcomp8a.sh', which checks the
# same thing for non-libtool objects.

required='cc libtoolize'
. test-init.sh

cat >> configure.ac << 'END'
AC_PROG_CC
#x AM_PROG_CC_C_O
AM_PROG_AR
AC_PROG_LIBTOOL
AC_OUTPUT
END

cat > Makefile.am << 'END'
## FIXME: stop disabling the warnings in the 'unsupported' category
## FIXME: once the 'subdir-objects' option has been mandatory.
AUTOMAKE_OPTIONS = -Wno-unsupported
lib_LTLIBRARIES = libzardoz.la
libzardoz_la_SOURCES = foo.c sub/bar.c
END

mkdir sub
echo 'int foo (void) { return 0; }' > foo.c
echo 'int bar (void) { return 0; }' > sub/bar.c

libtoolize

$ACLOCAL
# FIXME: stop disabling the warnings in the 'unsupported' category
# FIXME: once the 'subdir-objects' option has been mandatory.
$AUTOMAKE -a -Wno-unsupported
grep '\.P' Makefile.in # For debugging.
grep '\./\$(DEPDIR)/foo\.Plo' Makefile.in
grep '\./\$(DEPDIR)/bar\.Plo' Makefile.in
grep '/\./\$(DEPDIR)' Makefile.in && exit 1

$AUTOCONF
# Don't reject slower dependency extractors, for better coverage.
./configure --enable-dependency-tracking
$MAKE
DISTCHECK_CONFIGURE_FLAGS='--enable-dependency-tracking' $MAKE distcheck

# Try again with subdir-objects option.

echo AUTOMAKE_OPTIONS += subdir-objects >> Makefile.am

$AUTOMAKE
grep '\.P' Makefile.in # For debugging.
grep '\./\$(DEPDIR)/foo\.Plo' Makefile.in
grep '[^a-zA-Z0-9_/]sub/\$(DEPDIR)/bar\.Plo' Makefile.in
$EGREP '/(\.|sub)/\$\(DEPDIR\)' Makefile.in && exit 1

$AUTOCONF
# Don't reject slower dependency extractors, for better coverage.
./configure --enable-dependency-tracking
$MAKE
DISTCHECK_CONFIGURE_FLAGS='--enable-dependency-tracking' $MAKE distcheck

:
