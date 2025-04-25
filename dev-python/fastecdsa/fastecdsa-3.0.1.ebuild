# Copyright 1999-2020 Gentoo Authors
#                2025 krisk0
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_13 )

inherit distutils-r1

DESCRIPTION="Python library for fast elliptic curve crypto"
HOMEPAGE="https://github.com/AntonKueltz/fastecdsa"

LICENSE="CC0-1.0"
SLOT="0"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="${PYTHON_DEPS}"
DEPEND="${PYTHON_DEPS}"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3

	EGIT_REPO_URI="https://github.com/AntonKueltz/fastecdsa.git"
	EGIT_BRANCH="master"
	SRC_URI=""
	KEYWORDS=""
else
	SRC_URI="$HOMEPAGE/releases/download/v$PV/fastecdsa-${PV}.tar.gz"
	KEYWORDS=amd64
fi
