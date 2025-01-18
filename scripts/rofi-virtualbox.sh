#!/usr/bin/env bash
#
# https://github.com/okraits/rofi-tools/blob/master/rofi-virtualbox/rofi-virtualbox
#
# script to manage virtualbox machines with rofi
#
# dependencies: rofi, virtualbox

ROFI_CMD="rofi -dmenu -i"
OPTIONS="Start VM\nPower-off VM\nClone VM\nDelete VM"

# function definitions
######################

function vmsList()
{
  vboxmanage list vms | awk -F '"' '{print $2}'
  #vboxmanage list runningvms | awk -F '"' '{print "Running: "$2}'
}

function startVM()
{
  vboxmanage startvm "$1" --type headless
}

function poweroffVM()
{
  vboxmanage controlvm "$1" acpipowerbutton --type headless
}

function cloneVM()
{
  vboxmanage clonevm "$1" --mode machine --register --options keepallmacs
}

function deleteVM()
{
  vboxmanage unregistervm "$1" --delete
}

# script execution starts here
##############################

while true
do
  # select machine to control
  vm=$(vmsList | $ROFI_CMD -p 'Select VM')
  retval=$?
  [ $retval -ne 0 ] && exit $retval
  # select action to be executed
  option=$(echo -e $OPTIONS | $ROFI_CMD -p 'Select action')
  retval=$?
  [ $retval -ne 0 ] && exit $retval
  case "$option" in
    "Start VM")
      startVM "$vm"
      ;;
    "Power-off VM")
      poweroffVM "$vm"
      ;;
    "Clone VM")
      cloneVM "$vm"
      ;;
    "Delete VM")
      deleteVM "$vm"
      ;;
    *)
      exit 1
      ;;
  esac
done
