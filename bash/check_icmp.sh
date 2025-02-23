#!/bin/bash

# Check if tcpdump is installed
if ! command -v tcpdump &> /dev/null; then
  echo "Error: tcpdump is not installed. Install it with:"
  echo "  sudo apt install tcpdump  # Debian/Ubuntu"
  echo "  sudo dnf install tcpdump  # RHEL/CentOS"
  exit 1
fi

if [ "$(id -u)" != "0" ]; then
  echo "Error: This script requires root privileges (to capture packets)."
  echo "Run it with: sudo $0"
  exit 1
fi

# Capture ICMP packets on all interfaces
echo "[*] Monitoring ICMP packets (press Ctrl+C to stop)..."
tcpdump -i any -n icmp