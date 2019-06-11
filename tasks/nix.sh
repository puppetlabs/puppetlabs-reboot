#!/usr/bin/env bash
export PATH=$PATH:/usr/sbin:/sbin
set -e

if [[ $EUID > 0 ]]
then
  echo "{\"Error\": \"Run as root or sudo; use the '--user root' option to run it as root user or the '--run-as root --sudo-password' options to run it with sudo in Bolt tasks or plans.\"}"
  exit 1
fi

if [ -n "$PT_timeout" ]; then
  timeout=$PT_timeout
else
  timeout=3
fi

if [ -n "$PT_message" ]; then
  message=$PT_message
fi

# Force a minimum timeout of 3 second to allow the task response to be delivered.
if [ $timeout -lt 3 ]; then
  timeout=3
fi

if [[ `uname -s` == 'SunOS' ]]; then
  shutdown -y -i 6 -g $timeout $message </dev/null >/dev/null 2>&1 &
else
  # Linux only supports timeout in minutes. Handle the remainder with sleep.
  timeout_min=$(($timeout/60))
  timeout_sec=$(($timeout%60))
  nohup bash -c "sleep $timeout_sec; shutdown -r +$timeout_min $message" </dev/null >/dev/null 2>&1 &
  disown
fi

# There are some weird race conditions that might make detached jobs still die
# when this shell exits. The sync (which otherwise shouldn't do much) seems to
# eliminate them.
sync

echo "{\"status\":\"queued\",\"timeout\":$timeout}"
