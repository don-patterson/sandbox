#!/bin/bash
# Checks the state of the hard drive. can be active/idle, standby,
# or a few others (but haven't seen anything else before)
sudo hdparm -C /dev/sda
