# Copyright 1999-2024 Gentoo Authors
#                2025 krisk0
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1 pypi

DESCRIPTION="Python Bitcoin Library"
HOMEPAGE="https://github.com/1200wd/bitcoinlib"
SRC_URI="$(pypi_sdist_url "${PN}" "${PV}")"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="test"

RDEPEND="
    >=dev-python/fastecdsa-2.0[${PYTHON_USEDEP}]
    >=dev-python/base58-2.0[${PYTHON_USEDEP}]
    >=dev-python/requests-2.20.0[${PYTHON_USEDEP}]
    >=dev-python/sqlalchemy-1.3.0[${PYTHON_USEDEP}]
    >=dev-python/pyaes-1.6.0[${PYTHON_USEDEP}]
    >=dev-python/ecdsa-0.13[${PYTHON_USEDEP}]
    >=dev-python/pycryptodome-3.7.0[${PYTHON_USEDEP}]
    >=dev-python/dnspython-1.15.0[${PYTHON_USEDEP}]
"

BDEPEND="
    test? (
        ${RDEPEND}
        dev-python/pytest[${PYTHON_USEDEP}]
    )
"

distutils_enable_tests pytest

python_prepare_all() {
    # Remove tests directory to prevent installation in site-packages
    rm -rf tests || die

    distutils-r1_python_prepare_all
}

python_test() {
    # We need to recreate the tests directory for testing
    cp -r "${S}"/tests "${BUILD_DIR}" || die
    cd "${BUILD_DIR}" || die
    epytest -x tests
}
