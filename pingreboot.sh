#!/system/bin/sh
#version 2.1

log -t PingReboot "PingReboot: checking for /sdcard/pingreboot file"
[ -f /sdcard/pingreboot ] || log -t PingReboot "/sdcard/pingreboot not existing, not starting PingReboot"; exit
log -t PingReboot "PingReboot: started"

# These values can be overridden by putting them
# in $CONF_FILE with a custom value.
# Simply copy & paste lines you want to change.
#
PING_HOST="google.com"
RUN_EVERY=30
REENABLE_EVERY=4
REBOOT_AFTER=10

DEVICE=$(ip route get 8.8.8.8 | sed -nr 's/.*dev ([^\ ]+).*/\1/p')
source /sdcard/pingreboot

c=0
while true; do
  if ping -c 1 "$PING_HOST" > /dev/null; then
    c=0
  else
    c=$((c+1))
    log -t PingReboot "PingReboot: network failure, could not ping $PING_HOST (c=$c)"
    if (( $c > $REBOOT_AFTER )); then
       reboot
    elif (( $c % $REENABLE_EVERY == 0 )); then
      log -t PingReboot "PingReboot: re-enabling $DEVICE"
      ifconfig down $DEVICE
      sleep 4
      ifconfig up $DEVICE
      log -t PingReboot "PingReboot: device $DEVICE re-enabled"
    fi
  fi
  sleep $RUN_EVERY
done
