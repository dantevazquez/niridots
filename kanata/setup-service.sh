#!/bin/sh
set -e

echo "1. Configuring /etc/sv/kanata/run..."
mkdir -p /etc/sv/kanata

cat << 'RUN' > /etc/sv/kanata/run
#!/bin/sh
exec 2>&1
export PATH="/usr/local/bin:/usr/bin:/bin"
exec chpst -u void:input:uinput /usr/local/bin/kanata --cfg /home/void/.config/kanata/kanata.kbd --no-wait
RUN

chmod +x /etc/sv/kanata/run

mkdir -p /etc/sv/kanata/log
cat << 'LOG' > /etc/sv/kanata/log/run
#!/bin/sh
exec vlogger -t kanata -p daemon
LOG
chmod +x /etc/sv/kanata/log/run

echo "2. Ensuring symlink in /var/service..."
ln -sf /etc/sv/kanata /var/service/

echo "3. Stopping any manually running kanata instances..."
pkill -x kanata || true

echo ""
echo "Done! Waiting for runit supervisor to start kanata..."
sleep 3
sv status kanata || true
