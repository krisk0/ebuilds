# `ebuild` scripts

useful for me and possibly for you, too.

Reason for creating `gmpy2-...ebuild`: official .ebuild is dated (hard to use that `gmpy2` from Cython).

Reason for creating `gmp-...ebuild`: official .ebuild installs crippled library (without microarch optimisation).

## Installation (quick/hacker way)

Supposing all pre-requisites met, the fastest way to compile/install software is to call `ebuild` directly.

1. Put .ebuild close to its ancestor:
```
cp gmp-6.1.2-r99.ebuild /usr/portage/dev-libs/gmp/
```

2. Run `ebuild` script:
```
ebuild --skip-manifest /usr/portage/dev-libs/gmp/gmp-6.1.2-r99.ebuild clean install
```

`ebuild ... install` installs compiled files into a temporary directory such as `/tmp/portage/dev-libs/gmp-6.1.2-r99/image`.

`ebuild ... install qmerge` installs compiled files into a temp directory and their final destination such as `/usr/lib`.

Don't forget to `rm -rf /tmp/portage` after `qmerge`.
