# Copyright 2021 Денис Крыськов aka krisk0
# Distributed under the terms of the GNU General Public License v2

# Deprecation warnings are shown when compiling, ignore them
# TODO: why compilation is not multitasked?

EAPI=7

PYTHON_COMPAT=( python2_7 )

DISTUTILS_USE_SETUPTOOLS=manual
inherit distutils2

MY_PN=islpy
MY_P=$MY_PN-$PV
DESCRIPTION="Python wrapper around ISL"
HOMEPAGE=https://pypi.org/project/islpy/
SRC_URI=mirror://pypi/${PN:0:1}/${MY_PN}/${MY_P}.tar.gz

LICENSE=MIT
SLOT=0
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
RESTRICT=test

S="${WORKDIR}/${MY_PN}-${PV}"

BDEPEND="
	dev-python/setuptools-python2[${PYTHON_USEDEP}]
    dev-python/six-python2
    dev-python/pybind11-python2
"

PATCHES=( "${FILESDIR}"/python2_and_ffs.patch )
