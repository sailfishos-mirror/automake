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

# Test remake rules for m4 files included (also recursively) by
# aclocal.m4.  Keep in sync with sister tests:
#   - remake-include-configure.sh
#   - remake-include-makefile.sh

. test-init.sh

magic1=::MagicStringOne::
magic2=__MagicStringTwo__
magic3=%%MagicStringThree%%

if using_gmake; then
  remake="$MAKE nil"
else
  remake="$MAKE Makefile"
fi

cat >> configure.ac <<END
AC_CONFIG_MACRO_DIR([m4])
FINGERPRINT='my_fingerprint'
AC_SUBST([FINGERPRINT])
AC_OUTPUT
END

cat > Makefile.am <<'END'
.PHONY: nil
nil:
## Used by "make distcheck" later.
check-local:
	test -f $(top_srcdir)/m4/foo.m4
	test ! -r $(top_srcdir)/m4/bar.m4
	test x'$(FINGERPRINT)' = x'DummyValue'
END

mkdir m4
echo 'AC_DEFUN([my_fingerprint], [BadBadBad])' > m4/foo.m4

$ACLOCAL
$AUTOCONF
$AUTOMAKE

for vpath in : false; do

  if $vpath; then
    mkdir build
    cd build
    top_srcdir=..
  else
    top_srcdir=.
  fi

  $top_srcdir/configure
  $MAKE # Should be a no-op.

  $sleep
  echo "AC_DEFUN([my_fingerprint], [$magic1])" > $top_srcdir/m4/foo.m4
  $remake
  $FGREP FINGERPRINT Makefile # For debugging.
  $FGREP $magic1 Makefile

  $sleep
  echo "AC_DEFUN([my_fingerprint], [$magic2])" > $top_srcdir/m4/foo.m4
  $remake
  $FGREP FINGERPRINT Makefile # For debugging.
  $FGREP $magic1 Makefile && exit 1
  $FGREP $magic2 Makefile

  $sleep
  echo "m4_include([m4/bar.m4])" > $top_srcdir/m4/foo.m4
  echo "AC_DEFUN([my_fingerprint], [$magic3])" > $top_srcdir/m4/bar.m4
  $remake
  $FGREP FINGERPRINT Makefile # For debugging.
  $FGREP $magic1 Makefile && exit 1
  $FGREP $magic2 Makefile && exit 1
  $FGREP $magic3 Makefile

  $sleep
  echo "AC_DEFUN([my_fingerprint], [$magic1])" > $top_srcdir/m4/bar.m4
  $remake
  $FGREP $magic2 Makefile && exit 1
  $FGREP $magic3 Makefile && exit 1
  $FGREP $magic1 Makefile

  $sleep
  echo "AC_DEFUN([my_fingerprint], [DummyValue])" > $top_srcdir/m4/foo.m4
  echo "AC_DEFUN([AM_UNUSED], [NoSuchMacro])" > $top_srcdir/m4/bar.m4
  using_gmake || $remake
  $MAKE distcheck
  $FGREP $magic1 Makefile && exit 1 # Sanity check.
  $FGREP $magic2 Makefile && exit 1 # Likewise.
  $FGREP $magic3 Makefile && exit 1 # Likewise.

  $MAKE distclean

  cd $top_srcdir

done

:
