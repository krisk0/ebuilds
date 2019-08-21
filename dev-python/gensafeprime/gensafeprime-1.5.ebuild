# Copyright 2016 Крыськов Денис

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1

DESCRIPTION="Use OpenSSL to make prime n such that (n-1)/2 is prime"
HOMEPAGE=https://github.com/eriktews/gensafeprime
SRC_URI="$HOMEPAGE/archive/v$PV.zip -> $P.zip"
LICENSE=MIT
SLOT=0
KEYWORDS=amd64
IUSE=""

RDEPEND=dev-libs/openssl

#TODO: insert gensafeprime.generate(bit_lenght) into documentation
