#!/usr/bin/bash
#
# https://github.com/calebstewart/rofi-libvirt-mode
#
# rofi script to manage libvirt virtual machines
#
# dependencies: rofi, libvirt

mainMenu() {
  echo -en "\0prompt\x1fDomain >\n"
  for domain in $(virsh list --all --name); do
    echo -en "$domain\0"
    echo -en "icon\x1fcomputer\x1f"
    echo -en "info\x1fdomainMenu\x1f"
    echo -en "\n"
  done
}

domainMenu() {
  domain="$1"
  state=$(virsh dominfo --domain "$domain" | grep "State" | tr -s ' ' | cut -d' ' -f2)

  echo -en "\0prompt\x1fDomain > $domain >\n"


  if [ "$state" == "running" ]; then
    echo -en "View\0"
    echo -en "icon\x1fvideo-display\x1f"
    echo -en "info\x1f$domain\x1f"
    echo -en "\n"

    echo -en "Shutdown\0"
    echo -en "icon\x1fsystem-shutdown\x1f"
    echo -en "info\x1f$domain\x1f"
    echo -en "\n"
  else
    echo -en "Start\0"
    echo -en "icon\x1fmedia-playback-start\x1f"
    echo -en "info\x1f$domain\x1f"
    echo -en "\n"
  fi

  echo -en "Configure\0"
  echo -en "icon\x1fpreferences-system\x1f"
  echo -en "info\x1f$domain\x1f"
  echo -en "\n"
}

# If no arguments are provided, show the main menu
if [ "$#" -eq 0 ]; then
  mainMenu
  exit
fi

# Parse the option name
case "$1" in

  # Start a VM
  "Start")
    domain="$ROFI_INFO"

    # Close standard output so that rofi doesn't lock up
    exec >&-

    # Show a notification that we are working. Starting a VM
    # can take time depending on what resources need reserving.
    id=$(notify-send --urgency=low \
                     --icon=computer \
                     --print-id \
                     "Starting $domain...")

    # Start the VM. This is a blocking call.
    output=$(virsh start "$domain")

    # shellcheck disable=2181
    if [ "$?" -eq 0 ]; then
      # The domain started (or is booting)
      # Replace our old notification
      notify-send --urgency=low \
                  --icon=computer \
                  --transient \
                  --replace-id="$id" \
                  "Domain $domain Started"
    else
      # The domain failed to start
      # Replace our old notification
      notify-send --urgency critical\
                  --icon=computer-fail \
                  --expire-time=5000 \
                  --replace-id="$id" \
                  "Failed to Start $domain" \
                  "$output"
    fi
    ;;

  # Open VM configuration
  "Configure")
    nohup virt-manager --connect "$LIBVIRT_DEFAULT_URI" --show-domain-editor "$ROFI_INFO" >/dev/null 2>&1 &
    ;;

  # Open VM viewer
  "View")
    nohup virt-viewer --connect="$LIBVIRT_DEFAULT_URI" "$ROFI_INFO" >/dev/null 2>&1 &
    ;;

  # Request a VM shutdown
  "Shutdown")
    domain="$ROFI_INFO"

    # Close standard output so that rofi doesn't lock up
    exec >&-

    # Show a notification that we are working. Starting a VM
    # can take time depending on what resources need reserving.
    id=$(notify-send --urgency=low \
                     --icon=computer \
                     --print-id \
                     "Requesting Shutdown for $domain...")

    # Start the VM. This is a blocking call.
    output=$(virsh shutdown "$domain")

    # shellcheck disable=2181
    if [ "$?" -eq 0 ]; then
      # The domain started (or is booting)
      # Replace our old notification
      notify-send --urgency=low \
                  --icon=computer \
                  --transient \
                  --replace-id="$id" \
                  "Domain $domain Shutting Down"
    else
      # The domain failed to start
      # Replace our old notification
      notify-send --urgency critical\
                  --icon=computer-fail \
                  --expire-time=5000 \
                  --replace-id="$id" \
                  "Failed to Shutdown $domain" \
                  "$output"
    fi
    ;;

  # Any other options are assumed to be a VM domain name
  *)
    domainMenu "$1"
    ;;
esac
