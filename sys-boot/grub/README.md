# Building GRUB

To build GRUB without reiser4 filesystem support, use `grub-0.97-r23.ebuild`. To build reiser4-aware GRUB, use `grub-0.97-r24.ebuild`.

A detailed instruction of building the latter follows. To build the former, do what it says, but don't bother with libaal or reiser4progs because they are not needed, and emerge or ebuild `grub-0.97-r23` rather than `grub-0.97-r24`.

## Quick/hacker way of installation

Change to `ebuilds` directory (one with `sys-libs/ sys-fs/ sys-boot/ README.md`). Run the following shell script:
```sh
for i in sys-libs/libaal/libaal-1.0.7-r1 sys-fs/reiser4progs/reiser4progs-1.2.1-r1 \
        sys-boot/grub/grub-0.97-r24.ebuild ; do
    ABI_X86="32 64" USE='static-libs -custom-cflags' \
    ebuild --skip-manifest $i clean install qmerge || exit
done
```

## Official/slow/cautious method of installation

1. Make sure `portage` does not install official ebuilds for libaal or reiser4progs: place file with four lines
```
<sys-libs/libaal-1.0.7-r1
>sys-libs/libaal-1.0.7-r1
<sys-fs/reiser4progs-1.2.1-r1
>sys-fs/reiser4progs-1.2.1-r1
```
into `/etc/portage/package.mask/` directory. If this is not a directory but file, append the 4 lines.

2. Place 3 ebuilds (for libaal, reiser4progs, grub) into your overlay directory (that is where you keep non-standard ebuilds). If you don't have the overlay, skip this step.
```sh
cp -r sys-libs/ sys-fs/ sys-boot/ YOUR_OVERLAY
```

3. If using overlay, change to `YOUR_OVERLAY`. Create manifests for the three ebuilds:
```sh
ebuild sys-libs/libaal/libaal-1.0.7-r1.ebuild digest
ebuild sys-fs/reiser4progs/reiser4progs-1.2.1-r1 digest
ebuild sys-boot/grub/grub-0.97-r24.ebuild digest
```

4. If using overlay, run emerge like that:
```sh
ABI_X86="32 64" USE='static-libs -custom-cflags' emerge --ask =sys-boot/grub-0.97-r24
```

If not, then change to `ebuilds` directory (with `sys-libs/ sys-fs/ sys-boot/` subdirectories) and prepend `PORTDIR_OVERLAY` setting:

```sh
PORTDIR_OVERLAY=`pwd` \
ABI_X86="32 64" USE='static-libs -custom-cflags' emerge --ask =sys-boot/grub-0.97-r24
```
