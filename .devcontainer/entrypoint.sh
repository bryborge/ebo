#!/bin/bash

set -euo pipefail

# TODO: Clean this up, make more robust

# mount binfmt_misc so we can register the qemu binaries
mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
# reset
find /proc/sys/fs/binfmt_misc -type f -name 'qemu-*' -exec sh -c 'echo -1 > "$1"' shell {} \;

echo ":qemu-aarch64:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-aarch64-static:F" > /proc/sys/fs/binfmt_misc/register
