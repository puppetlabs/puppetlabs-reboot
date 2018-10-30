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

if [[ `uname -s` == 'SunOS' ]]; then
  shutdown -y -i 6 -g $timeout $message </dev/null >/dev/null 2>&1 &
else
  # Round to minutes
  if [ $timeout -gt 0 ]; then
    let timeout_min=($timeout+59)/60
    let timeout=$timeout_min*60
    shutdown -r +${timeout_min} $message </dev/null >/dev/null 2>&1 &
  else
    shutdown -r 0 $message </dev/null >/dev/null 2>&1 &
  fi
fi

echo "{\"status\":\"queued\",\"timeout\":$timeout}"

