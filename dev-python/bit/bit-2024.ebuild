# Copyright 2026 krisk0
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

COMMIT=45ce495338f86bac8ee85b88aaa75813cdd50808

inherit distutils-r1 pypi

DESCRIPTION="Fast and easy-to-use Bitcoin library"
HOMEPAGE=https://github.com/ofek/bit
SRC_URI="$HOMEPAGE/archive/$COMMIT.tar.gz -> $P.tar.gz"
S=${WORKDIR}/${PN}-${COMMIT}

LICENSE=MIT
SLOT=0
KEYWORDS=amd64

RDEPEND="
	dev-python/coincurve[${PYTHON_USEDEP}]
	dev-python/cryptography[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
" # coincurve is at bitcoin overlay https://gitlab.com/bitcoin/gentoo

python_prepare_all() {
	# remove misplaced tests directory so install phase does not fail
	rm -r tests || die

	distutils-r1_python_prepare_all
}

distutils_enable_tests pytest
