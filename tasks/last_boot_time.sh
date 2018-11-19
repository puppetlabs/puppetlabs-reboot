#!/bin/sh
if [ $(uname) = Darwin ]; then
  last -1 reboot
else
  last -1 -F reboot
fi
