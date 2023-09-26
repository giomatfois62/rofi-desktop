## rofi-desktop

rofi-desktop is a collection of scripts launching interactive [rofi](https://github.com/davatorium/rofi) menus, aiming to provide the functionalities of a complete desktop environment. 

The main menu is accessed with *rofi-desktop.sh*, together with a comprehensive system settings menu and a menu of simple utilities. This script supports an optional argument to determine which enties to show:
```
./scripts/rofi-desktop.sh -d # shows main menu entries
./scripts/rofi-desktop.sh -c # shows custom user menus
./scripts/rofi-desktop.sh -s # shows file search menu
./scripts/rofi-desktop.sh -s # shows settings menu
./scripts/rofi-desktop.sh -u # shows utilities menu
./scripts/rofi-desktop.sh -w # shows web search menu
./scripts/rofi-desktop.sh -a # shows all the menu entries
```

The *config/config.env* file contains the scripts' variables that can be customized by the user. Source this file somewhere (like in ~/.bashrc) to override their default values.

Users can easily create custom menus editing the *rofi-desktop.sh* script or by putting simple json files, containing the list of entries with corresponding commands to run and optional icons to show, in the *scripts/menus* folder.  
Visit the [rofi-json](https://github.com/luiscrjunior/rofi-json) repo for details on the syntax to use for custom entries.

All the scripts can be run on their own, perhaps binded to a keyboard shortcut, and are easy to inspect and modify. Currently implemented functionalities are:
- Applications Menu (drun modi)
- Run Command (run modi)
- Browse Files (filebrowser modi)
- Search Computer (rofi-search.sh, search files in home directory using find or fd if available)
  - All Files 
  - Recent Files
  - File Contents (search file contents with grep or ripgrep if available)
  - Bookmarks (rofi-firefox.sh, search bookmarks from firefox default profile)
  - Books
  - Desktop
  - Documents
  - Downloads
  - Music
  - Pictures (with big thumbnails preview)
  - Videos
- Search Web (rofi-web-search.sh, gives real time search suggestions when modi blocks is available)
  - Google
  - Wikipedia
  - Youtube
  - Archwiki
  - Reddit (rofi-reddit.sh, filter subreddits and display search results)
  - Flathub (rofi-flathub.sh, filter applications list and install selected)
  - 1377x.to (rofi-torrent.sh, search torrents and open selected magnet links)
- Steam Games (rofi-steam.sh)
- Sport Events (rofi-livetv.sh, show current and upcoming sport events with relative streaming links)
- Podcasts (rofi-podcast.sh, browse and play podcasts from rss.com)
- Latest News (rofi-news.sh, fetch rss news from bbc international and other providers)
- Weather Forecast (curl wttr.in piped to rofi)
- Watch TV (rofi-tv.sh, stream TV channels with mpv)
- Web Radio (rofi-radio.sh, stream Radios with mpv)
- Utilities
  - Calculator (rofi-calc.sh, optionally uses the libqalc based modi calc when available)
  - Calendar (rofi-calendar.sh)
  - World Clocks (show current date-time in system timezones)
  - Color Picker (rofi-color-picker.sh)
  - ChatGPT (rofi-gpt.sh)
  - Dictionary (rofi-dict.sh)
  - Media Player (rofi-playerctl.sh)
  - MPD Controls (rofi-mpd.sh, controls mpd using mpc commands)
  - Translate Text (rofi-translate.sh, uses translate-shell)
  - Notes (rofi-notes.sh)
  - TODO Lists (rofi-todo.sh)
  - Set Timer (rofi-timer.sh)
  - Characters (rofi-characters.sh, utf-8 char and emoji picker)
  - Take Screenshot (rofi-screenshot.sh, autodetects and uses various screenshot programs)
  - Record Audio/Video (rofi-ffmpeg.sh)
  - SSH Sessions (ssh modi)
  - Cheat Sheets (rofi-cheat.sh, show cheat.sh sheets)
  - Code Projects (rofi-projects.sh, browse code projects directory and open projects with preferred editor)
  - Tmux Sessions (rofi-tmux.sh)
  - Password Manager (rofi-passmenu.sh)
  - KeePassXC (rofi-keepassxc.sh)
  - Clipboard (uses greenclip)
  - Notifications (uses rofication-daemon.py and rofication-gui.py)
  - Task Manager (launch htop or pipe it's output to rofi if modi blocks is available)
- System Settings
  - Appearance (Qt, GTK, rofi style and wallpaper setter with big thumbnails)
  - Network (networkmanager_dmenu.sh)
  - VPN (wireguard-rofi.sh, manages wireguard connections)
  - Bluetooth (rofi-bluetooth.sh)
  - Display (rofi-monitor-layout.sh)
  - Default Applications (rofi-mime.sh, set audio/video/images/PDF viewers and file manager)
  - Autostart Applications (rofi-autostart.sh, manage xdg/autostart desktop files)
  - Keyboard Layout (rofi-keyboard-layout.sh)
  - Brightness (rofi-brightness.sh, uses xbacklight)
  - Volume (rofi-volume.sh, uses pactl and pavucontrol)
  - Menu Configuration (edit all rofi-desktop scripts)
  - Language (rofi-locale.sh, set LC_ALL for user session)
  - System Services (rofi-systemd.sh)
  - Update System (update-system.sh)
  - System Info (inxi piped to rofi)
  - Install Programs (rofi-flathub.sh)
  - Rofi Shortcuts (keys modi)
- Session Menu (uses loginctl and optional custom lock command)
  - Lock Screen, Log Out, Suspend, Reboot, Shutdown, Hibernate

## Gallery
[gif of the menus](https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/demo.webm)

Main Menu
![Main Menu](https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_all.png)
Settings Menu
![Settings Menu](https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_settings.png)
Utilities Menu
![Utilities Menu](https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_utils.png)
File Search Menu
![File Search Menu](https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_search.png)
Web Search Menu
![Web Search Menu](https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_web.png)

## Global Menu
The script *scripts/rofi-hud.py* shows a rofi menu containing the application menu entries of the currently focused window, in a style similar to Ubuntu Unity's HUD or [plasma-hud](https://github.com/Zren/plasma-hud).  

In order for it to work, applications menus first need to be exported via dbus by a special service. The KDE desktop automatically launch such service when the global menu plugin is added to a panel. [vala-panel](https://github.com/rilian-la-te/vala-panel-appmenu) also contains a similar plugin, which can be used with Mate and Xfce panels.  

Alternatively, run the script *scripts/appmenu-service.py* bundled with rofi-desktop, which provides a partial implementation of the service (Note: programs launched before executing the script need to be restarted in order to export their menus).

## Meta/Alt Key Triggers
Most window managers and desktop environments make it impossible or very hard to bind custom keyboard shortcuts using only single modifier keys, like the Meta key or the Alt key.  
These simple shortcuts are very useful to quickly summon the menus of rofi-desktop.  

A nice little utility that can be used to bind the Meta key to a shortcut of choice is [superkey-launch](https://github.com/ryanpcmcquen/superkey-launch), which by default converts Meta key presses to the "Alt+F2" shortcut.  

Alternatively, run the script *scripts/keypress.py* bundled with rofi-desktop. It will listen for single key presses of the Meta key and the Alt key, calling respectively the all-in-one menu *scripts/rofi-desktop.sh -a* and the application menu *scripts/rofi-hud.py*. Edit the script variables *cmd_command* and *alt_command* to change this behaviour.

## Dependencies
The only mandatory dependency is rofi, but it's easy to convert most of the scripts to use fzf instead.  
Optional dependencies for some of the tools are: 
- jq
- curl
- wget
- mpv 
- rofi-blocks
- rofi-calc
- xrandr
- ffmpeg 
- pactl 
- fd
- ripgrep
- htop 
- inxi
- xbacklight
- at
- pass
- greenclip
- translate-shell
- jsonpickle
- zenity
- shell_gpt
- FontAwesome
- sdcv
- xclip
- xsel
- xdotool
- playerctl
- python3-xlib
- python3-lxml
- python3-requests
- steam
- qt5ct
- lxappearance
- setxkbmap
- tmux
- sqlite
- firefox
- links
- mpd
- mpc
- keepassxc-cli
- wireguard
- nmcli
- bluetoothctl

## Credits
Some of the scripts in rofi-desktop where adapted from the work of the following people:
- [firecat53](https://github.com/firecat53/networkmanager-dmenu) 
- [nickclyde](https://github.com/nickclyde/rofi-bluetooth)
- [BelkaDev](https://github.com/BelkaDev/RofiFtw)
- [Davatorium](https://github.com/davatorium/rofi-scripts)
- [mnabila](https://github.com/mnabila/dotfiles/blob/master/scripts/dmenu_ffmpeg)
- [claudiodangelis](https://github.com/claudiodangelis/rofi-todo)
- [christianholman](https://github.com/christianholman/rofi_notes)
- [luiscrjunior](https://github.com/luiscrjunior/rofi-json)
- [lamarios](https://github.com/lamarios/dotfiles/blob/master/scripts/rofi-firefox)
- [emmanuelrosa](https://gist.github.com/emmanuelrosa/1f913b267d03df9826c36202cf8b1c4e)
- [adi1090x](https://gitee.com/zhenruyan/rofi/blob/master/scripts/menu_backlight.sh)
- [ntcarlson](https://github.com/ntcarlson/dotfiles/tree/delta/config/rofi)
- [zx2c4](https://git.zx2c4.com/password-store/tree/contrib/dmenu/passmenu)
- [Bavuett](https://github.com/Bavuett/rofi-dev-launcher)
- [haxguru](https://www.reddit.com/r/unixporn/comments/10w7p5z/rofi_chatgpt_rofi/)
- [windwp](https://github.com/windwp/rofi-color-picker)
- [colonelpanic8](https://github.com/colonelpanic8/rofi-systemd)
- [mrHeavenli](https://github.com/mrHeavenli/rofi-playerctl)
- [RafaelBocquet](https://github.com/RafaelBocquet/i3-hud-menu)
- [BarbUk](https://github.com/BarbUk/snippy)
- [Bugswriter](https://github.com/Bugswriter/pirokit)
- [Prayag2](https://github.com/Prayag2/pomo)
- [wzykubek](https://github.com/wzykubek/rofi-mpd)
- [HarHarLinks](https://github.com/HarHarLinks/wireguard-rofi-waybar)
