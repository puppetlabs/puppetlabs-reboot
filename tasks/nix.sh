#!/usr/bin/env bash
set -e

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
fi

echo "{\"status\":\"queued\",\"timeout\":$timeout}"

