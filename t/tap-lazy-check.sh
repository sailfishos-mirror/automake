#! /bin/sh
# Copyright (C) 2011-2012 Free Software Foundation, Inc.
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
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# TAP support: AM_LAZY_CHECK

. ./defs || exit 1

cat > Makefile.am << 'END'
TEST_LOG_COMPILER = cat
TESTS = foo.test bar.test baz.test
baz.log: zardoz
END

. "$am_testauxdir"/tap-setup.sh || fatal_ "sourcing tap-setup.sh"

: > zardoz

cat > foo.test <<'END'
1..2
ok 1
ok 2
END

cat > bar.test <<'END'
1..1
not ok 1
END

cat > baz.test <<'END'
1..1
Bail out!
END

# Even the tests that are not re-run should contribute to the testsuite
# summary when obtained by "make check AM_LAZY_CHECK=yes".
grep_summary ()
{
  grep '^# TOTAL: *4$' stdout
  grep '^# PASS: *2$' stdout
  grep '^# XPASS: *0$' stdout
  grep '^# FAIL: *1$' stdout
  grep '^# XFAIL: *0$' stdout
  grep '^# SKIP: *0$' stdout
  grep '^# ERROR: *1$' stdout
}

$MAKE check && exit 1
test -f foo.log
test -f bar.log
test -f baz.log

rm -f foo.log bar.log

$MAKE AM_LAZY_CHECK=yes check > stdout && { cat stdout; exit 1; }
cat stdout
test -f foo.log
test -f bar.log
grep '^PASS: foo\.test 1$' stdout
grep '^PASS: foo\.test 2$' stdout
grep '^FAIL: bar\.test 1$' stdout
grep 'baz\.test' stdout && exit 1
grep_summary

$sleep
touch foo.test
# We re-run only a successful test, but the tests that failed in the
# previous run should still be taken into account, and cause an overall
# failure.
$MAKE AM_LAZY_CHECK=yes check > stdout && { cat stdout; exit 1; }
cat stdout
grep '^PASS: foo\.test 1$' stdout
grep '^PASS: foo\.test 2$' stdout
grep 'ba[rz]\.test' stdout && exit 1
is_newest foo.log foo.test
grep_summary

$sleep
touch zardoz
$MAKE AM_LAZY_CHECK=yes check > stdout && { cat stdout; exit 1; }
cat stdout
grep '^ERROR: baz\.test' stdout
$EGREP '(foo|bar)\.test' stdout && exit 1
is_newest baz.log zardoz
grep_summary

# Now, explicitly retry with all test logs already updated, and ensure
# that the summary is still displayed.
$MAKE AM_LAZY_CHECK=yes check > stdout && { cat stdout; exit 1; }
cat stdout
$EGREP '(foo|bar|baz)\.test' stdout && exit 1
grep_summary

: