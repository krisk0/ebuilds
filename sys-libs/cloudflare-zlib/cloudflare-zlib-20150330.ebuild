# Copyright 1999-2014 Gentoo Foundation
# Copyright      2016 Денис Крыськов
# Distributed under the terms of the GNU General Public License v2

# Reason for creating this ebuild: want a fast CRC32 calculation (for modern
#  Intel 64-bit CPU) which is found in Linux kernel and Cloudflare fork of zlib

EAPI=4
AUTOTOOLS_AUTO_DEPEND=no

inherit autotools toolchain-funcs multilib multilib-minimal

z=libCloudflareZ
DESCRIPTION="zlib library, forked by Cloudflare, installed as $z.*"
HOMEPAGE=https://github.com/cloudflare/zlib
sha=a80420c63532c25220a54ea0980667c02303460a
SRC_URI="$HOMEPAGE/archive/$sha.tar.gz -> $P.tar.gz"

LICENSE=ZLIB
SLOT=0
KEYWORDS=amd64
IUSE=static-libs

DEPEND=""
RDEPEND=""

src_unpack() {
 default
 mv zlib-* $P || die
}

src_prepare() {
 sed -i configure -e s:,libz.so.1:,$z.so.1:g
 multilib_copy_sources
}

echoit() { echo "$@"; "$@"; }

multilib_src_configure() {
 case ${CHOST} in
 *-mingw*|mingw*)
  ;;
 *)      # not an autoconf script, so can't use econf
  local uname=$("${EPREFIX}"/usr/share/gnuconfig/config.sub "${CHOST}" |\
   cut -d- -f3) #347167
  echoit ./configure \
   --shared \
   --prefix="${EPREFIX}/usr" \
   --libdir="${EPREFIX}/usr/$(get_libdir)" \
   ${uname:+--uname=${uname}} \
   || die
  ;;
 esac
}

multilib_src_compile() {
 einfo "If compilation fails, add -march=native to CFLAGS" 
 case ${CHOST} in
 *-mingw*|mingw*)
  emake -f win32/Makefile.gcc STRIP=true PREFIX=${CHOST}-
  sed \
   -e 's|@prefix@|${EPREFIX}/usr|g' \
   -e 's|@exec_prefix@|${prefix}|g' \
   -e 's|@libdir@|${exec_prefix}/'$(get_libdir)'|g' \
   -e 's|@sharedlibdir@|${exec_prefix}/'$(get_libdir)'|g' \
   -e 's|@includedir@|${prefix}/include|g' \
   -e 's|@VERSION@|'${PV}'|g' \
   zlib.pc.in > zlib.pc || die
  ;;
 *)
  emake
  ;;
 esac
}

multilib_src_install() {
 case ${CHOST} in
 *-mingw*|mingw*)
  emake -f win32/Makefile.gcc install \
   BINARY_PATH="${ED}/usr/bin" \
   LIBRARY_PATH="${ED}/usr/$(get_libdir)" \
   INCLUDE_PATH="${ED}/usr/include" \
   SHARED_MODE=1
  ;;
 *)
  emake install DESTDIR="${D}" LDCONFIG=:
  ;;
 esac

 local l=$(get_libdir)
 cd "${ED}/usr/$l" || die
 use static-libs || rm -f lib{z,minizip}.{a,la} #419645
 rm -r pkgconfig libz.so libz.so.? || die
 for l in libz.* ; do
  mv $l `echo $l|sed s:libz:$z:` || die
 done
 for l in libC*.so* ; do
  local a=${l%.*}
  ln -s $l $a      || die
  a=${a%.*}
  ln -s $l $a || die
  ln -s $l ${a%.*} || die
 done
}

src_install() {
 multilib-minimal_src_install
 rm -r "${ED}/usr/share" "${ED}/usr/include" || die
 unset z
}
