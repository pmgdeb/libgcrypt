#!/bin/sh
# Run this to generate all the initial makefiles, etc.
# Copyright (C) 2002, 2003 Free Software Foundation, Inc.
#
# This file is part of Libgcrypt.
#
# Libgcrypt is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
#
# Libgcrypt is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA

PGM=LIBGCRYPT

autoconf_vers=2.53
automake_vers=1.6
aclocal_vers=1.5
libtool_vers=1.4

DIE=no
if test "$1" = "--build-w32"; then
    tsdir=$(cd `dirname $0`; cd ..; pwd)
    shift
    host=i386--mingw32
    if [ ! -f $tsdir/scripts/config.guess ]; then
        echo "$tsdir/scripts/config.guess not found" >&2
        exit 1
    fi
    build=`$tsdir/scripts/config.guess`
        
    if ! mingw32 --version >/dev/null; then
        echo "We need at least version 0.3 of MingW32/CPD" >&2
        exit 1
    fi

    if [ -f "$tsdir/config.h" ]; then
        if grep HAVE_DOSISH_SYSTEM config.h | grep undef >/dev/null; then
            echo "Pease run a 'make distclean' first" >&2
            exit 1
        fi
    fi

    crossbindir=`mingw32 --install-dir`/bin
    CC=`mingw32 --get-path gcc`
    CPP=`mingw32 --get-path cpp`
    AR=`mingw32 --get-path ar`
    RANLIB=`mingw32 --get-path ranlib`
    export CC CPP AR RANLIB 

    disable_foo_tests=""
    if [ -n "$lib_config_files" ]; then
        for i in $lib_config_files; do
            j=`echo $i | tr '[a-z-]' '[A-Z_]'`
            eval "$j=${crossbindir}/$i"
            export $j
            disable_foo_tests="$disable_foo_tests --disable-`echo $i| \
                           sed 's,-config$,,'`-test"
            if [ ! -f "${crossbindir}/$i" ]; then                   
                echo "$i not installed for MingW32" >&2
                DIE=yes
            fi
        done
    fi
    [ $DIE = yes ] && exit 1

    $tsdir/configure --build=${build} --host=${host} \
                ${disable_foo_tests} $*
    exit $?
fi



if (autoconf --version) < /dev/null > /dev/null 2>&1 ; then
    if (autoconf --version | awk 'NR==1 { if( $3 >= '$autoconf_vers') \
			       exit 1; exit 0; }');
    then
       echo "**Error**: "\`autoconf\'" is too old."
       echo '           (version ' $autoconf_vers ' or newer is required)'
       DIE="yes"
    fi
else
    echo
    echo "**Error**: You must have "\`autoconf\'" installed to compile $PGM."
    echo '           (version ' $autoconf_vers ' or newer is required)'
    DIE="yes"
fi

if (automake --version) < /dev/null > /dev/null 2>&1 ; then
  if (automake --version | awk 'NR==1 { if( $4 >= '$automake_vers') \
			     exit 1; exit 0; }');
     then
     echo "**Error**: "\`automake\'" is too old."
     echo '           (version ' $automake_vers ' or newer is required)'
     DIE="yes"
  fi
  if (aclocal --version) < /dev/null > /dev/null 2>&1; then
    if (aclocal --version | awk 'NR==1 { if( $4 >= '$aclocal_vers' ) \
						exit 1; exit 0; }' );
    then
      echo "**Error**: "\`aclocal\'" is too old."
      echo '           (version ' $aclocal_vers ' or newer is required)'
      DIE="yes"
    fi
  else
    echo
    echo "**Error**: Missing "\`aclocal\'".  The version of "\`automake\'
    echo "           installed doesn't appear recent enough."
    DIE="yes"
  fi
else
    echo
    echo "**Error**: You must have "\`automake\'" installed to compile $PGM."
    echo '           (version ' $automake_vers ' or newer is required)'
    DIE="yes"
fi


#if (gettext --version </dev/null 2>/dev/null | awk 'NR==1 { split($4,A,"\."); \
#    X=10000*A[1]+100*A[2]+A[3]; echo X; if( X >= 1035 ) exit 1; exit 0}')
#    then
#    echo "**Error**: You must have "\`gettext\'" installed to compile $PGM."
#    echo '           (version 0.10.35 or newer is required; get'
#    echo '            ftp://alpha.gnu.org/gnu/gettext-0.10.35.tar.gz'
#    echo '            or install the latest Debian package)'
#    DIE="yes"
#fi


if (libtool --version) < /dev/null > /dev/null 2>&1 ; then
    if (libtool --version | awk 'NR==1 { if( $4 >= '$libtool_vers') \
			       exit 1; exit 0; }');
    then
       echo "**Error**: "\`libtool\'" is too old."
       echo '           (version ' $libtool_vers ' or newer is required)'
       DIE="yes"
    fi
else
    echo
    echo "**Error**: You must have "\`libtool\'" installed to compile $PGM."
    echo '           (version ' $libtool_vers ' or newer is required)'
    DIE="yes"
fi


if test "$DIE" = "yes"; then
    exit 1
fi

#echo "Running gettextize...  Ignore non-fatal messages."
#echo "no" | gettextize --force
echo "Running libtoolize...  Ignore non-fatal messages."
echo "no" | libtoolize

run()
{
    echo "Running $@..."
    $@
}

run aclocal
run autoheader
run automake --gnu -a
run autoconf

echo "You can now run \"./configure --enable-maintainer-mode\" and then \"make\"."