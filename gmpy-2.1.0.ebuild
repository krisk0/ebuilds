# Copyright 1999-2017 Gentoo Foundation
# Copyright      2018 Денис Крыськов
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )
# I only tested python2_7: PYTHON_TARGETS=python2_7 ebuild ...

inherit distutils-r1

MY_PN=${PN}2
MY_VER=${PV}a4
RESTRICT=mirror

DESCRIPTION="Python bindings for GMP, MPC, MPFR and MPIR libraries"
HOMEPAGE=https://github.com/aleaxit/$PN
SRC_URI=$HOMEPAGE/releases/download/$MY_PN-2.1a4/$MY_PN-$MY_VER.tar.gz

LICENSE=LGPL-2.1
SLOT=2
KEYWORDS=amd64   # did not try other arch
IUSE=mpir   # did not try mpir. Don't know how to install documentation

RDEPEND="
	>=dev-libs/mpc-1.0.2
	>=dev-libs/mpfr-3.1.3
	!mpir? ( dev-libs/gmp:0= )
	mpir? ( sci-libs/mpir )"
DEPEND="${RDEPEND}
	app-arch/unzip"

S="${WORKDIR}"/$MY_PN

src_unpack() {
    default
    mv $PN* $MY_PN
}

python_configure_all() {
	mydistutilsargs=(
		$(use mpir --mpir)
		)
}

python_compile() {
	python_is_python3 || local -x CFLAGS="${CFLAGS} -fno-strict-aliasing"
	distutils-r1_python_compile
}

python_compile_all() {
	#use doc && emake -C docs html -- this works, I don't know how to install it
    :
}

# did not try to test
python_test() {
	cd test || die
	"${PYTHON}" runtests.py || die "tests failed under ${EPYTHON}"
	if python_is_python3; then
		cd ../test3 || die
	else
		cd ../test2 || die
	fi
	"${PYTHON}" gmpy_test.py || die "tests failed under ${EPYTHON}"
}
