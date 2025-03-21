## Replacement for AC_PROG_LEX.                            -*-  Autoconf -*-
## by Alexandre Oliva <oliva@dcc.unicamp.br>
# Copyright (C) 1998-2025 Free Software Foundation, Inc.
#
# This file is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# AM_PROG_LEX([OPTIONS])
# ----------------------
# Autoconf leaves LEX=: if lex or flex can't be found.  Change that to a
# "missing" invocation, for better error output.
AC_DEFUN([AM_PROG_LEX],
[AC_PREREQ([2.50])dnl
AC_REQUIRE([AM_MISSING_HAS_RUN])dnl
AC_PROVIDE_IFELSE([AC_PROG_LEX], [], [AC_PROG_LEX($@)])
dnl Do not dnl on previous line, or output has "fiif".
if test "$LEX" = :; then
  LEX=${am_missing_run}flex
fi])
