# `ebuild` scripts

useful for me and possibly for you, too.

As of 2023, all scripts found in this repository are obsolete (probably except for Python2 stuff). Use [ungoogled chromium ebuild](https://gpo.zugaina.org/www-client/ungoogled-chromium), and official ebuilds. Don't forget to set use flag `-cpudetection` when building GMP. See note below on fight over GMP ebuild.

Reason for creating `gmpy2-...ebuild`: official .ebuild is dated (hard to use that `gmpy2` from Cython).

Reason for creating `gmp-...ebuild`: official .ebuild installs crippled library (without microarch optimization).

**In 2015 my patch to un-cripple gmp ebuild was rejected by Gentoo developers without explanation. [Bug filed by me](https://bugs.gentoo.org/545442) was closed with no comment with resolution `won't fix`. The problem of crippled GMP was stated before in [2008](https://bugs.gentoo.org/235697). It was fixed in 2022 with gmp-6.3.0.ebuild. Now GMP installs properly optimized library when use flag `-cpudetection` is set (at least on AMD64 platform). It took three bug reports, at least one forum discussion and 14 years to convince Gentoo folks.**

Reason for messing up with `iridium-browser`: want a fast browser that does not segfault as often as Firefox and does not phone home as often as Chromium.

Reason for modifying `telegram-desktop...ebuild`: original did not work for me.

## Installation (quick/hacker way)

Supposing all pre-requisites met, the fastest way to compile/install software is to call `ebuild` directly.

1. Put .ebuild close to its ancestor:
```
cp gmp-6.2.1-r99.ebuild /usr/portage/dev-libs/gmp/
```

2. Run `ebuild` script:
```
ebuild --skip-manifest /usr/portage/dev-libs/gmp/gmp-6.2.1-r99.ebuild clean install qmerge
```

`ebuild ... install` installs compiled files into a temporary directory such as `/tmp/portage/dev-libs/gmp-6.2.1-r99/image`.

`ebuild ... install qmerge` installs compiled files into a temp directory and their final destination such as `/usr/lib64`.

Don't forget to clean `/tmp/portage` (or whatever your portage scratch dir is).

## Iridium-browser

Current status of `iridium-browser...ebuild`: compiles with settings
```
L10N=en-GB CFLAGS='-O2 -march=sandybridge' USE='-component-build -cups -custom-cflags -gnome-keyring -hangouts -jumbo-build -kerberos -proprietary-codecs -pulseaudio -suid -system-ffmpeg -system-icu -system-libvpx -tcmalloc -widevine'

```
, does not install due to file collisions with `chromium`.
