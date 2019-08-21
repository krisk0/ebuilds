# Copyright 1999-2017 Gentoo Foundation
#                2019 Денис Крыськов aka krisk0
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils toolchain-funcs usr-ldscript multilib-minimal

DESCRIPTION="reiser4 utilities and libraries"
HOMEPAGE="https://sourceforge.net/projects/reiser4"
SRC_URI="mirror://sourceforge/reiser4/$P.tar.gz"

LICENSE=GPL-2
SLOT=0
KEYWORDS="amd64 arm ppc ppc64 -sparc x86"
IUSE="debug readline static static-libs"

AAL_DEP=">=sys-libs/libaal-1.0.7-r1[static-libs(+),${MULTILIB_USEDEP}]"
LIB_DEPEND="$AAL_DEP
    readline? ( sys-libs/readline[static-libs(+),${MULTILIB_USEDEP}] )"
RDEPEND="!static? ( ${LIB_DEPEND//static-libs(+),} )
    static-libs? ( $AAL_DEP )"
DEPEND="$RDEPEND
    static? ( $LIB_DEPEND )"

PATCHES=( 
            "${FILESDIR}"/${PN}-1.0.7-readline-6.3.patch
            "${FILESDIR}"/${PN}-1.2.1-node40_sync.patch
        )

src_prepare() {
    # Upstream meant to compile minimal library with -Os. However it is not clear how to
    #  do this while respecting user CFLAGS. We just delete any O1 O2 O3 Os, so everything
    #  compiles with optimization from $CFLAGS
    sed -i -r \
        -e '/CFLAGS=/s: -static":":' \
        -e '/CFLAGS/s: (-O[123s]|-g)\>::g' \
        configure || die

    # plugin/key/key_common/key_common.h not found, so prepend ../
    sed -i 's:#include "plugin/key/key_common/:#include "../plugin/key/key_common/:' \
            `find -name '*.c' -or -name '*.h'`

    # <plugin/item/body40/body40.h> not found, also prepend ../
    sed -i 's:<plugin/item/:<../plugin/item/:' \
            `find -name '*.c' -or -name '*.h'`

    # "plugin/object/obj40/obj40.h" not found
    sed -i 's:include "plugin/object/:include "../plugin/object/:' \
            `find -name '*.c' -or -name '*.h'`

    default
}

multilib_src_configure() {
    >run-ldconfig
    chmod +x run-ldconfig

    local a=(
            $(use_enable static full-static)
            $(use_enable static-libs static)
            $(use_enable debug)
            $(use_with readline)
            --disable-Werror
            --enable-libminimal
            --sbindir=/sbin)
    ECONF_SOURCE="$S" econf "${a[@]}"
}

multilib_src_install() {
    default
    if multilib_is_native_abi ; then
        gen_usr_ldscript -a reiser4{,-minimal} repair
    fi
    unset AAL_DEP
}
