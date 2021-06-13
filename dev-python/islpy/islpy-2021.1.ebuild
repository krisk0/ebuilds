# Copyright 2021 Денис Крыськов aka krisk0
# Distributed under the terms of the GNU General Public License v2

# Deprecation warnings are shown when compiling, ignore them
# TODO: why compilation is not multitasked?

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )

inherit distutils-r1

DESCRIPTION="Python wrapper around ISL"
HOMEPAGE=https://pypi.org/project/islpy/
SRC_URI=mirror://pypi/${PN:0:1}/$PN/$P.tar.gz

LICENSE=MIT
SLOT=0
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
RESTRICT=test

S="${WORKDIR}/${PN}-$PV"

BDEPEND="
    dev-python/six
    dev-python/pybind11
"

PATCHES=( "${FILESDIR}"/ffs.patch )
