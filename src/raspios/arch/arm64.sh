#!/bin/bash

export OS="raspios"
export IMAGE="2024-11-19-raspios-bookworm-arm64-lite.img"
export IMAGE_XZ="$IMAGE.xz"
export IMAGE_URL="https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2024-11-19/$IMAGE.xz"
export IMAGE_CHECKSUM="6ac3a10a1f144c7e9d1f8e568d75ca809288280a593eb6ca053e49b539f465a4"
export OUTPUT_IMAGE="golden-$IMAGE"
