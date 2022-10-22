## rofi-desktop

rofi-desktop is a collection of scripts launching interactive [rofi](https://github.com/davatorium/rofi) menus, aiming to provide the functionalities of a complete desktop environment. 

The main desktop menu is accessed with *rofi-desktop.sh*, while *rofi-settings.sh* contains a comprehensive system settings menu. 

Currently implemented functionalities are:
- Applications Menu (drun modi)
- Run Command (run modi)
- Browse Files (filebrowser modi)
- Search Computer (rofi-search, search files in home directory using find or fd if available)
  - All Files 
  - Bookmarks (from firefox default profile)
  - Books
  - Desktop
  - Documents
  - Downloads
  - Music
  - Pictures (with big thumbnails preview)
  - Videos
- Search Web (rofi-web-search, gives real time search suggestions when modi blocks is available)
  - Google
  - Wikipedia
  - Youtube
  - Archwiki
- Latest News (rofi-news, rss news from bbc international)
- Weather Forecast (curl wttr.in piped to rofi)
- Watch TV (rofi-tv, stream TV channels with mpv)
- Web Radio (rofi-radio, stream Radios with mpv)
- Utilities
  - Calculator (rofi-calc, optionally uses the libqalc based modi calc when available)
  - Calendar (rofi-calendar)
  - Notepad (rofi-notes)
  - To-Do List (rofi-todo)
  - Take Screenshot (autodetects and uses various screenshot programs)
  - Record Audio/Video (rofi-ffmpeg)
  - SSH (ssh modi)
- System Settings
  - Appearance (Qt, GTK, rofi style and wallpaper setter with big thumbnails)
  - Network (networkmanager_dmenu)
  - Bluetooth (rofi-bluetooth)
  - Display (rofi-monitor-layout.sh)
  - Volume (uses pactl and pavucontrol)
  - Menu Configuration (edit all rofi-desktop scripts)
  - Task Manager (launch htop or pipe it's output to rofi if modi blocks is available)
  - System Info (inxi piped to rofi)
- Session Menu (uses loginctl and optional custom lock command)
  - Lock Screen, Log Out, Suspend, Reboot, Shutdown, Hibernate

All the scripts can be run on their own, perhaps binded to a keyboard shortcut, and are easy to inspect and modify. 

The only mandatory dependency is rofi, but it's easy to convert most of the scripts to use fzf instead. 
Optional dependencies for some of the tools are: jq mpv rofi-blocks rofi-calc ffmpeg pactl fd htop inxi

## Credits
Some of the scripts in rofi-desktop where adapted from the work of the following people:
- [firecat53](https://github.com/firecat53/networkmanager-dmenu) 
- [nickclyde](https://github.com/nickclyde/rofi-bluetooth)
- [BelkaDev](https://github.com/BelkaDev/RofiFtw)
- [Davatorium](https://github.com/davatorium/rofi-scripts)
- [mnabila](https://github.com/mnabila/dotfiles/blob/master/scripts/dmenu_ffmpeg)
- [claudiodangelis](https://github.com/claudiodangelis/rofi-todo)
- [christianholman](https://github.com/christianholman/rofi_notes)
