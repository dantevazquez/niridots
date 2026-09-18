#!/bin/sh
set -e

echo "1. Cleaning up /etc/modules-load..."
rm -f /etc/modules-load.

echo "2. Writing /etc/modules-load.d/uinput.conf..."
mkdir -p /etc/modules-load.d
echo "uinput" > /etc/modules-load.d/uinput.conf

echo "3. Writing /etc/udev/rules.d/99-input.rules..."
mkdir -p /etc/udev/rules.d
echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' > /etc/udev/rules.d/99-input.rules

echo "4. Setting /dev/uinput permissions..."
chown root:uinput /dev/uinput 2>/dev/null || true
chmod 660 /dev/uinput 2>/dev/null || true
udevadm control --reload-rules 2>/dev/null || true

echo ""
echo "Successfully configured! Verification:"
echo "--- /etc/modules-load.d/uinput.conf ---"
cat /etc/modules-load.d/uinput.conf
echo "--- /etc/udev/rules.d/99-input.rules ---"
cat /etc/udev/rules.d/99-input.rules
echo "--- /dev/uinput ---"
ls -l /dev/uinput
