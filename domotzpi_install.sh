#!/bin/bash

# Function to handle errors
handle_error() {
  echo "Error: $1" >&2
  exit 1
}

# Update the package index files on the system
apt-get update || handle_error "Failed to update package index"

# Install snapd - Snapcraft store daemon
apt-get install snapd || handle_error "Failed to install snapd"

# Install the Domotz Pro agent snap package
snap install domotzpro-agent-publicstore || handle_error "Failed to install Domotz Pro agent"

# Grant the Domotz Pro agent package needed permissions
snap connect domotzpro-agent-publicstore:firewall-control
snap connect domotzpro-agent-publicstore:network-observe
snap connect domotzpro-agent-publicstore:raw-usb
snap connect domotzpro-agent-publicstore:shutdown
snap connect domotzpro-agent-publicstore:system-observe

# Load the "tun" module needed for VPN On Demand feature
modprobe tun || handle_error "Failed to load the tun module"
grep -qxF "tun" /etc/modules || echo "tun" >> /etc/modules

# Disable the module libarmmem that conflicts with the snap package
# This preloaded module conflicts with the snap package, causing VPN On Demand not to work.
sed -i 's|/usr/lib/arm-linux-gnueabihf/libarmmem-${PLATFORM}.so|#/usr/lib/arm-linux-gnueabihf/libarmmem-${PLATFORM}.so|' /etc/ld.so.preload

# Comment out the line with "Include /etc/ssh/ssh_config.d/*.conf"
# This setting conflicts with the snap package environment, preventing remote sessions.
sed -i 's/^Include \/etc\/ssh\/ssh_config\.d\/\*\.conf/#&/' /etc/ssh/ssh_config

# Restart the snap package
snap restart domotzpro-agent-publicstore || handle_error "Failed to restart Domotz Pro agent"
