# Copyright 1999-2015 Gentoo Foundation
# Copyright      2019 Денис Крыськов aka krisk0
# Distributed under the terms of the GNU General Public License v2

# Warning: this ebuild currently fails to compile anything useful

# XXX: we need to review menu.lst vs grub.conf handling.  We've been converting
#      all systems to grub.conf (and symlinking menu.lst to grub.conf), but
#      we never updated any of the source code (it still all wants menu.lst),
#      and there is no indication that upstream is making the transition.

EAPI=5

inherit eutils toolchain-funcs linux-info flag-o-matic autotools pax-utils

DESCRIPTION="GNU GRUB boot loader with reiser 4 support"
HOMEPAGE="https://www.gnu.org/software/grub"
SRC_URI="mirror://gentoo/${P}.tar.gz mirror://gnu-alpha/${PN}/${P}.tar.gz"

LICENSE=GPL-2
SLOT=0
KEYWORDS="amd64 ~x86 ~x86-fbsd"
IUSE="custom-cflags ncurses netboot"

DEPEND="virtual/pkgconfig 
ncurses? ( >=sys-libs/ncurses-5.9-r3:0[static-libs,abi_x86_32] )
sys-fs/reiser4progs[static-libs,abi_x86_32]
"

pkg_setup() {
    case $(tc-arch) in
    amd64) CONFIG_CHECK='~IA32_EMULATION' check_extra_config ;;
    esac
}

src_prepare() {
    # Grub will not handle a kernel larger than EXTENDED_MEMSIZE Mb as
    # discovered in #160801. We can change this; however, using larger values
    # for this variable means that Grub needs more memory to run and boot. For a
    # kernel of size N, Grub needs (N+1)*2.
    [ .${GRUB_MAX_KERNEL_SIZE} == . ] && {
        case $(tc-arch) in
        amd64) GRUB_MAX_KERNEL_SIZE=9 ;;
        *)   GRUB_MAX_KERNEL_SIZE=5 ;;
        esac
    }
    einfo "Grub will support kernel of size ${GRUB_MAX_KERNEL_SIZE}M"

    sed -i \
        "/^#define.*EXTENDED_MEMSIZE/s,3,${GRUB_MAX_KERNEL_SIZE},g" \
        grub/asmstub.c \
        || die

    # reiser4 patches
    epatch "$FILESDIR"/grub-0.97-reiser4-20060227.diff
    # insert -fno-stack-protector like 011_all_grub-0.97-varargs does
    #sed -i 's|$(GRUB_CFLAGS)|\0 -fno-stack-protector|' stage2/Makefile.am
    
    # Fix memcheck() procedure so it works when RAM size is >2G, #99897
    #epatch "$FILESDIR"/grub-0.97-2G_memcheck.diff
    # Crunched 820_all_grub-0.97-cvs-sync.patch (debian 0.97-47)
    #epatch "$FILESDIR"/820-grub-0.97-debian47.diff

    # #564890, #566638, and other
    local skip_em t b skip_this
    # Omit graphic patches; splash will be unavailable
    # Omit no-stack-protector patch -- already applied
    # Omit 012_all_grub-0.97-gcc46 -- GCC 4.6 compatibility not required
    skip_em="
            001_all_grub-0.95.20040823-splash
            002_all_grub-0.97-splashimage-safety
            011_all_grub-0.97-varargs
            012_all_grub-0.97-gcc46
            "
    for t in "$FILESDIR"/*.patch ; do
        b=`basename "$t"`
        skip_this=`echo $skip_em|fgrep -c ${b%.patch}`
        [ $skip_this == 0 ] && epatch $t
    done
    # gcc wants no-pie switch rather than nopie
    sed -i 's:-nopie:-no-pie:g' configure.ac || die

    rm -f aclocal.m4 # seems to keep #418287 away
    eautoreconf
}

src_configure() {
    filter-flags -fPIE #168834

    use amd64 && multilib_toolchain_setup x86

    unset BLOCK_SIZE #73499

    ### i686-specific code in the boot loader is a bad idea; disabling to ensure
    ### at least some compatibility if the hard drive is moved to an older or
    ### incompatible system.

    # grub-0.95 added -fno-stack-protector detection, to disable ssp for stage2,
    # but the objcopy's (faulty) test fails if -fstack-protector is default.
    # create a cache telling configure that objcopy is ok, and add -C to econf
    # to make use of the cache.
    #
    # CFLAGS has to be undefined before econf, so -fno-stack-protector check succeeds.
    # STAGE2_CFLAGS is not allowed to be used on emake command-line, it overwrites
    # -fno-stack-protector detected by configure, removed from netboot's emake.
    use custom-cflags || unset CFLAGS

    tc-ld-disable-gold #439082 #466536 #526348

    export grub_cv_prog_objcopy_absolute=yes #79734
    append-ldflags -static

    # Configure net-bootable grub first, if "netboot" is set
    if use netboot ; then
        mkdir -p "${WORKDIR}"/netboot
        pushd "${WORKDIR}"/netboot >/dev/null
        ECONF_SOURCE=${S} \
        econf \
            --libdir=/lib \
            --datadir=/usr/lib/grub \
            --exec-prefix=/ \
            --disable-auto-linux-mem-opt \
            --enable-diskless \
            --enable-{3c{5{03,07,09,29,95},90x},cs89x0,davicom,depca,eepro{,100}} \
            --enable-{epic100,exos205,ni5210,lance,ne2100,ni{50,65}10,natsemi} \
            --enable-{ne,ns8390,wd,otulip,rtl8139,sis900,sk-g16,smc9000,tiara} \
            --enable-{tulip,via-rhine,w89c840}
        popd >/dev/null
    fi

    # Configure regular grub
    # Note that FFS and UFS2 support are broken for now - stage1_5 files too big
    econf \
        --libdir=/lib \
        --datadir=/usr/lib/grub \
        --exec-prefix=/ \
        --disable-auto-linux-mem-opt \
        $(use_with ncurses curses)

    # check if important libs are found
    use ncurses && ! grep -qs "HAVE_LIBCURSES.*1" config.h &&
            die "ncurses use flag is set but the library is not found"
    grep -qs "HAVE_LIBREISER4_MINIMAL.*1" config.h ||
            die "reiser4-minimal library with mmap support not found"
            
    # -nostdlib switch results in multiple symbol-not-defined errors. Like 
    #
    #   In function `cde40_get_name':(...): undefined reference to `__stack_chk_fail_local'
    #
    # Either -nostdlib should be removed, or extra libs should be added after -laal-minimal
    # We choose the second option: append -l...
    sed -i 's:-lreiser4-minimal -laal-minimal:\0 -lc -lgcc -lgcc_eh -lc:' \
        `find . -name Makefile` || die
}

src_compile() {
    use netboot && emake -C "${WORKDIR}"/netboot w89c840_o_CFLAGS="-O"
    emake
}

src_test() {
    # non-default block size also give false pass/fails.
    unset BLOCK_SIZE
    emake -j1 check
}

src_install() {
    default
    if use netboot ; then
        exeinto /usr/lib/grub/${CHOST}
        doexe "${WORKDIR}"/netboot/stage2/{nbgrub,pxegrub}
        newexe "${WORKDIR}"/netboot/stage2/stage2 stage2.netboot
    fi

    pax-mark -m "${D}"/sbin/grub #330745

    newdoc docs/menu.lst grub.conf.sample
    dodoc "${FILESDIR}"/grub.conf.gentoo

    insinto /usr/share/grub
}

setup_boot_dir() {
    local boot_dir=$1
    local dir=${boot_dir}

    mkdir -p "${dir}"
    [[ ! -L ${dir}/boot ]] && ln -s . "${dir}/boot"
    dir="${dir}/grub"
    if [[ ! -e ${dir} ]] ; then
        mkdir "${dir}" || die
    fi

    # change menu.lst to grub.conf
    if [[ ! -e ${dir}/grub.conf ]] && [[ -e ${dir}/menu.lst ]] ; then
        mv -f "${dir}"/menu.lst "${dir}"/grub.conf
        ewarn "*** IMPORTANT NOTE: menu.lst has been renamed to grub.conf"
        echo
    fi

    if [[ ! -e ${dir}/menu.lst ]]; then
        einfo "Linking from new grub.conf name to menu.lst"
        ln -snf grub.conf "${dir}"/menu.lst
    fi

    # backup old stage2, in case it differs
    [[ -e ${dir}/stage2 ]] && mv "${dir}"/stage2{,.old}

    einfo "Copying files from /lib/grub and /usr/share/grub to ${dir}"
    for x in \
            "${ROOT}"/lib*/grub/*/* \
            "${ROOT}"/usr/share/grub/* ; do
        [[ -f ${x} ]] && cp -p "${x}" "${dir}"/
    done

    # remove backup if it is duplicate
    cmp -s "${dir}"/stage2{,.old} && rm "${dir}"/stage2.old
    # if old file is different, warn user
    [[ -e ${dir}/stage2.old ]] && {
        local a="$ARCH.xml?part=1&chap=10#grub-install-auto"
        ewarn "*** IMPORTANT NOTE: you must run grub and install"
        ewarn "the new version's stage1 to your MBR.  Until you do,"
        ewarn "stage1 and stage2 will still be the old version, but"
        ewarn "later stages will be the new version, which could"
        ewarn "cause problems such as an unbootable system."
        ewarn
        ewarn "This means you must use either grub-install or perform"
        ewarn "root/setup manually."
        ewarn
        ewarn "For more help, see the handbook:"
        ewarn "https://www.gentoo.org/doc/en/handbook/handbook-$a"
        echo
    }

    [[ -e ${dir}/grub.conf ]] || {
        local s="$ROOT/usr/share/doc/$PF/grub.conf.gentoo"
        # TODO: should be better way to unpack .bz2 than ugly code below
        [[ -e $s ]] && cat "$s" >${dir}/grub.conf
        [[ -e $s.gz ]] && zcat "$s.gz" >${dir}/grub.conf
        [[ -e $s.bz2 ]] && bzcat "$s.bz2" >${dir}/grub.conf
    }

    # Don't know if we built grub that supports splash. Keep code below that copies the
    # graphic file, it is harmless
    local splash_xpm_gz="${ROOT}/usr/share/grub/splash.xpm.gz"
    local boot_splash_xpm_gz="${dir}/splash.xpm.gz"
    [[ -e ${splash_xpm_gz} ]] && [[ ! -e ${boot_splash_xpm_gz} ]] && \
        cp "${splash_xpm_gz}" "${boot_splash_xpm_gz}"

    # Per #218599, we support grub.conf.install for users that want to run a
    # specific set of Grub setup commands rather than the default ones.
    local grub_config=${dir}/grub.conf.install
    [[ -e ${grub_config} ]] || grub_config=${dir}/grub.conf
    [[ -e ${grub_config} ]] && {
        local e
        e='^[[:space:]]*(#|$|default|fallback|initrd|password|splashimage|timeout|title)'
        egrep \
            -v "$e" \
            "${grub_config}" | \
        /sbin/grub --batch \
            --device-map="${dir}"/device.map \
            > /dev/null
    }

    # the grub default commands silently piss themselves if
    # the default file does not exist ahead of time
    if [[ ! -e ${dir}/default ]] ; then
        grub-set-default --root-directory="${boot_dir}" default
    fi
    einfo "Grub has been installed to ${boot_dir} successfully."
}

pkg_config() {
    [[ -d $GRUB_ALT_INSTALLDIR ]] || {
        einfo "Enter the directory where you want to setup grub:"
        local dir
        read dir
        setup_boot_dir "$dir"
        return
    }
    setup_boot_dir "$GRUB_ALT_INSTALLDIR"
}
