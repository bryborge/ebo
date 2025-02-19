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

echo "Starting Raspberry Pi OS image build process..."

# Check for expected first argument.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <operating-system>"
    echo "Valid operating-systems: raspios"
    exit 1
fi

# Select the operating system to build (based on the first argument).
case $1 in
    "raspios")
        source ./scripts/raspios/build.sh
        ;;
    *)
        echo "Invalid operating system choice: $1"
        echo "Valid options are: raspios"
        exit 1
        ;;
esac

# Directories
export BASE_IMAGE_DIR="img"
export MOUNT_DIR="mnt"
export OUTPUT_DIR="out"

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
if [ ! sudo update-binfmts --display qemu-arm 2>/dev/null ]; then
    echo "Registering qemu-arm format..."
    sudo update-binfmts \
        --install qemu-arm /usr/bin/qemu-arm-static \
        --magic "\x7f\x45\x4c\x46\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00" \
        --mask "\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff"
else
    echo "qemu-arm format already registered."
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

sudo cp scripts/$OS/provision.sh "$MOUNT_DIR/tmp/"
sudo chmod +x "$MOUNT_DIR/tmp/provision.sh"

# Run the provisioning script in chroot
echo "Running provisioning in chroot..."
sudo chroot "$MOUNT_DIR" /bin/bash -c "/tmp/provision.sh"

# Clean up
echo "Cleaning up..."
sudo rm "$MOUNT_DIR/tmp/provision.sh"
sudo rm "$MOUNT_DIR/usr/bin/qemu-arm-static"

sudo umount "$MOUNT_DIR/dev/pts"
sudo umount "$MOUNT_DIR/dev"
sudo umount "$MOUNT_DIR/sys"
sudo umount "$MOUNT_DIR/proc"
sudo umount "$MOUNT_DIR/boot"
sudo umount "$MOUNT_DIR"

echo "Your golden image has finished baking! 🥧"
echo "Output image: $OUTPUT_DIR/$OUTPUT_IMAGE"
