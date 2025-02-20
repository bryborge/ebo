#!/bin/bash

# Fail immediately and loudly!
# -e:          Exit immediately if a command exits with a non-zero status.
# -u:          Treat unset variables as an error when substituting.
# -x:          Print commands and their arguments
# -o pipefail: The return value of a pipeline is the status of the last command to exit with a non-zero status,
#              or zero if no command exited with a non-zero status
set -euo pipefail
for arg in "$@"; do
    if [ "$arg" = "--debug" ];
    then
        set -x
        break
    fi
done

# Check for expected arguments.
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <architecture> <operating-system>"
    echo "Valid architectures: arm64, armhf"
    echo "Valid operating systems: raspios"
    exit 1
fi

# Set architecture-specific variables based on first argument.
case $1 in
    "arm64")
        QEMU_ARCH="aarch64"
        QEMU_BINARY="qemu-aarch64-static"
        BINFMT_MAGIC="\x7f\x45\x4c\x46\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00"
        BINFMT_MASK="\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff"
        ;;
    "armhf")
        QEMU_ARCH="arm"
        QEMU_BINARY="qemu-arm-static"
        BINFMT_MAGIC="\x7f\x45\x4c\x46\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00"
        BINFMT_MASK="\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff"
        ;;
    *)
        echo "Invalid architecture choice: $1"
        echo "Valid architectures: arm64, armhf"
        exit 1
        ;;
esac

# Select the operating system to build based on the second argument.
case $2 in
    "raspios")
        source ./src/$2/arch/$1.sh
        ;;
    *)
        echo "Invalid operating system choice: $2"
        echo "Valid operating systems: raspios"
        exit 1
        ;;
esac

# Directories
BASE_IMAGE_DIR="img"
MOUNT_DIR="mnt"
OUTPUT_DIR="out"

echo "Setting the oven to 375-degrees fahrenheit...🔥"

# Download the base image if not already present.
if [ ! -f "$BASE_IMAGE_DIR/$IMAGE" ];
then
    echo "Downloading $IMAGE..."
    wget -O "$BASE_IMAGE_DIR/$IMAGE_XZ" "$IMAGE_URL"

    echo "Verifying checksum..."
    echo "$IMAGE_CHECKSUM $BASE_IMAGE_DIR/$IMAGE_XZ" | sha256sum -c

    echo "Extracting image..."
    xz -d "$BASE_IMAGE_DIR/$IMAGE_XZ"
else
    echo "Using existing image file."
fi

# Copy the image for customization.
echo "Copying image for customization..."
if [ ! -f "$OUTPUT_DIR/$OUTPUT_IMAGE" ];
then
    cp "$BASE_IMAGE_DIR/$IMAGE" "$OUTPUT_DIR/$OUTPUT_IMAGE"
else
    echo "Output image already exists."
fi

# Ensure binfmt support for ARM emulation is setup.
echo "Registering $QEMU_ARCH format..."
if ! sudo update-binfmts --display "$QEMU_ARCH" 2>/dev/null;
then
    sudo update-binfmts \
        --install "$QEMU_ARCH" "/usr/bin/$QEMU_BINARY" \
        --magic "$BINFMT_MAGIC" \
        --mask "$BINFMT_MASK"
else
    echo "$QEMU_ARCH format already registered."
fi

# Mount the image partitions.
echo "Mounting image partitions..."
if findmnt "$MOUNT_DIR" >/dev/null || findmnt "$MOUNT_DIR/boot" >/dev/null;
then
    echo "Image partitions are already mounted."
else
    OFFSET_ROOT=$(fdisk -l "$OUTPUT_DIR/$OUTPUT_IMAGE" | grep Linux | tail -n 1 | awk '{print $2 * 512}')
    OFFSET_BOOT=$(fdisk -l "$OUTPUT_DIR/$OUTPUT_IMAGE" | grep Linux | head -n 1 | awk '{print $2 * 512}')
    sudo mount -o loop,offset=$OFFSET_ROOT "$OUTPUT_DIR/$OUTPUT_IMAGE" "$MOUNT_DIR"
    sudo mount -o loop,offset=$OFFSET_BOOT "$OUTPUT_DIR/$OUTPUT_IMAGE" "$MOUNT_DIR/boot"
fi

# Copy qemu-arm-static for chroot
sudo cp /usr/bin/qemu-arm-static "$MOUNT_DIR/usr/bin/"

# Prepare for chroot
echo "Preparing for chroot environment..."
if findmnt "$MOUNT_DIR/proc" >/dev/null || findmnt "$MOUNT_DIR/sys" >/dev/null || findmnt "$MOUNT_DIR/dev" >/dev/null;
then
    echo "Already in chroot environment."
else
    sudo mount -t proc /proc "$MOUNT_DIR/proc"
    sudo mount -t sysfs /sys "$MOUNT_DIR/sys"
    sudo mount -o bind /dev "$MOUNT_DIR/dev"
    sudo mount -o bind /dev/pts "$MOUNT_DIR/dev/pts"    
fi

sudo cp src/$OS/provisioner.sh "$MOUNT_DIR/tmp/"
sudo chmod +x "$MOUNT_DIR/tmp/provisioner.sh"

# Run the provisioning script in chroot
echo "Running provisioning script in chroot..."
sudo chroot "$MOUNT_DIR" /bin/bash -c "/tmp/provisioner.sh"

# Clean up
echo "Cleaning up..."
sudo rm "$MOUNT_DIR/tmp/provisioner.sh"
sudo rm "$MOUNT_DIR/usr/bin/qemu-arm-static"

sudo umount "$MOUNT_DIR/dev/pts"
sudo umount "$MOUNT_DIR/dev"
sudo umount "$MOUNT_DIR/sys"
sudo umount "$MOUNT_DIR/proc"
sudo umount "$MOUNT_DIR/boot"
sudo umount "$MOUNT_DIR"

echo "Your golden image has finished baking! 🥧"
echo "Output image: $OUTPUT_DIR/$OUTPUT_IMAGE"
