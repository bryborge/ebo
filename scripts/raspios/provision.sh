#!/bin/bash

set -e

# Update package lists
apt-get update

# Install packages
apt-get install -y vim git htop iotop net-tools curl wget

# Configure hostname
echo "raspberrypi-custom" > /etc/hostname
sed -i 's/raspberrypi/raspberrypi-custom/g' /etc/hosts

# Create user directories
mkdir -p /home/pi/apps /home/pi/scripts /home/pi/data
chown -R pi:pi /home/pi/apps /home/pi/scripts /home/pi/data

# # Create startup script
# cat << 'SCRIPT' > /home/pi/scripts/startup.sh
# #!/bin/bash
# echo "Custom RaspberryPi image built with direct image manipulation"
# date >> /home/pi/boot_history.log
# SCRIPT

# chmod +x /home/pi/scripts/startup.sh
# chown pi:pi /home/pi/scripts/startup.sh

# # Add startup script to crontab
# (crontab -l 2>/dev/null || true; echo "@reboot /home/pi/scripts/startup.sh") | crontab -u pi -

echo "Provisioning complete!"
