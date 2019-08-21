# Copyright 1999-2017 Gentoo Foundation
# Copyright      2019 Крыськов Денис aka krisk0
# Distributed under the terms of the GNU General Public License v2

# Reason for creating this ebuild: grub-0.97 wants 32-bit libaal, and official libaal
#  ebuild is not multilib-aware

EAPI=5

inherit eutils multilib-minimal

DESCRIPTION="library required by reiser4progs"
HOMEPAGE="https://sourceforge.net/projects/reiser4/"
SRC_URI="mirror://sourceforge/reiser4/${P}.tar.gz"

LICENSE=GPL-2
SLOT=0
KEYWORDS="amd64 arm ppc ppc64 -sparc x86"
IUSE="static-libs"

DEPEND="virtual/os-headers"

src_prepare() {
    # Upstream build system compiles regular library with -O3 flag and minimal library with
    #  -Os. We replace -O3 with user-specified CFLAGS
    sed -i "/GENERIC_CFLAGS/s:-O3:$CFLAGS:" configure || die 'sed'

    # use standard integer types from stdint.h
    epatch "${FILESDIR}"/${PN}-1.0.6-glibc26.patch
}

multilib_src_configure() {
    >run-ldconfig
    chmod +x run-ldconfig

    ECONF_SOURCE=${S} econf \
        --enable-libminimal \
        --enable-memory-manager \
        $(use_enable static-libs static)
}

multilib_src_install() {
    # 32-bit libraries get installed in /usr/lib32
    default
    # Magic below installs 64-bit dynamic libraries twice: in /lib64 and in /usr/lib64
    if multilib_is_native_abi ; then
        gen_usr_ldscript -a aal{,-minimal}
    fi
}
