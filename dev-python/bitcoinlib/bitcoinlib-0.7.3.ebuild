EAPI=8

PYTHON_COMPAT=( python3_{9..13} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1

DESCRIPTION="Python library for building Bitcoin and other cryptocurrency applications"
HOMEPAGE="https://github.com/1200wd/bitcoinlib"
SRC_URI="${HOMEPAGE}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

BDEPEND="
    dev-python/setuptools[${PYTHON_USEDEP}]
    dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

DEPEND="
    dev-python/fastecdsa[${PYTHON_USEDEP}]
    dev-python/requests[${PYTHON_USEDEP}]
    dev-python/base58[${PYTHON_USEDEP}]
    dev-python/sqlalchemy[${PYTHON_USEDEP}]
    dev-python/pycryptodome[${PYTHON_USEDEP}]
    dev-python/qrcode[${PYTHON_USEDEP}]
    dev-python/pillow[${PYTHON_USEDEP}]
"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${PV}"

python_prepare_all() {
    export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}

    # Inject setup.cfg to exclude tests package
    cat > setup.cfg <<-EOF || die
[metadata]
name = bitcoinlib
version = ${PV}

[options]
packages = find:
include_package_data = true

[options.packages.find]
where = .
exclude =
    tests
EOF

    distutils-r1_python_prepare_all
}
