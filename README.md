## rofi-desktop

rofi-desktop is a collection of scripts launching interactive [rofi](https://github.com/davatorium/rofi) menus, aiming to provide the functionalities of a complete desktop environment. 

The main menu is accessed with *rofi-desktop.sh*, together with a comprehensive system settings menu and a menu of simple utilities. This script supports an optional argument to determine which enties to show:
```
./scripts/rofi-desktop.sh -d # shows main menu entries
./scripts/rofi-desktop.sh -c # shows custom user menus
./scripts/rofi-desktop.sh -f # shows file search menu
./scripts/rofi-desktop.sh -s # shows settings menu
./scripts/rofi-desktop.sh -u # shows utilities menu
./scripts/rofi-desktop.sh -w # shows web search menu
./scripts/rofi-desktop.sh -a # shows all the menu entries
```

The *scripts/config/environment* file contains the scripts' variables that can be customized by the user. Source this file somewhere (like in ~/.bashrc) to override their default values.

## Scripts

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
  - Archwiki
  - Youtube
  - Youtube Feeds (rofi-youtube-feeds.sh, browse youtube channels feeds, based on [yt-feeder](https://github.com/xcdkz/YT-Feeder))
  - GitHub (rofi-github.sh, search github and clone or open repositories)
  - Reddit (rofi-reddit.sh, filter subreddits and display search results)
  - Flathub (rofi-flathub.sh, filter applications list and install selected)
  - 1377x.to (rofi-torrent.sh, search torrents and open selected magnet links)
  - bitsearch.to (rofi-bitsearch.sh, search torrents and open selected magnet links)
  - eBooks (rofi-books.sh, search books on annas-archive and open download page)
  - xkcd (rofi-xkcd.sh, browse and view xkcd comics in rofi)
  - Anime (rofi-anime.sh, stream anime with mpv, based on [ani-cli](https://github.com/pystardust/ani-cli))
- Steam Games (rofi-steam.sh)
- Sport Events (rofi-livetv.sh, show current and upcoming sport events with relative streaming links)
- Podcasts (rofi-podcast.sh, browse and play podcasts from rss.com)
- Latest News (rofi-news.sh, fetch rss news from bbc international and other providers)
- Weather Forecast (curl wttr.in piped to rofi)
- Watch Movies/Series (rofi-streaming.sh, stream movies/series with mpv, based on [lobster](https://github.com/justchokingaround/lobster))
- Watch TV (rofi-tv.sh, stream TV channels with mpv)
- Web Radio (rofi-radio.sh, stream Radios with mpv)
- Utilities
  - Calculator (rofi-calc.sh, optionally uses the libqalc based modi calc when available)
  - Calendar (rofi-calendar.sh)
  - Contacts (rofi-contacts.sh, read .vcf files and shows list of contacts with emails and phone numbers)
  - World Clocks (show current date-time in system timezones)
  - Color Picker (rofi-color-picker.sh)
  - Dictionary (rofi-dict.sh)
  - Media Controls (rofi-playerctl.sh)
  - Music Player (rofi-mpd.sh, controls mpd using mpc commands)
  - Translate Text (rofi-translate.sh, uses translate-shell)
  - Notes (rofi-notes.sh)
  - ToDo Lists (rofi-todo-list.sh and rofi-todo.sh)
  - Set Timer (rofi-timer.sh)
  - Characters (rofi-characters.sh, utf-8 char and emoji picker)
  - Take Screenshot (rofi-screenshot.sh, autodetects and uses various screenshot programs)
  - Record Audio/Video (rofi-ffmpeg.sh)
  - SSH Sessions (ssh modi)
  - Cheat Sheets (rofi-cheat.sh, show cheat.sh sheets)
  - Code Projects (rofi-projects.sh, browse code projects directory and open projects with preferred editor)
  - Fortune (rofi-fortune.sh, show fortunes optionally with cowsay)
  - Hangman (rofi-hangman.sh, play hangman with many word categories)
  - Trivia (rofi-quiz.py, answer trivia questions from Open Trivia DB)
  - Tmux Sessions (rofi-tmux.sh)
  - Password Manager (rofi-passmenu.sh)
  - KeePassXC (rofi-keepassxc.sh)
  - Clipboard (rofi-clip.sh, uses greenclip in x11 or cliphist in wayland)
  - Notifications (uses rofication-daemon.py and rofication-gui.py)
  - Switch Window (window modi)
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
  - Brightness (rofi-brightness.sh, uses xrandr)
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

<img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_all.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_utils.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_settings.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_search.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_web.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_session.png" width="30%"><img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_appear.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_calendar.png" width="30%"> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_autostart.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_chars.png" width="30%"><img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi-colors.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_cheat1.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_cheat2.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_default1.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_default2.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_dict.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_flathub.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_fortune.png" width="30%"><img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_todo.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_github.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_keyboard.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_lang.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_media.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_monitor.png" width="30%"><img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_timer.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_mpd.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_news.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_news2.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_podcast1.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_podcast2.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_podcast3.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_reddit1.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_reddit2.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_radio.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_record.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_sport.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_timezone.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_torrent.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_trans.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_firefox.png" width="30%"></img><img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_tnt.png" width="30%"></img><img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_top.png" width="30%"></img><img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_youtube1.png" width="30%"></img><img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_youtube2.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_tv.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_volume.png" width="30%"></img> <img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_weather.png" width="30%"></img><img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_xkcd.png" width="30%"></img><img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_hangman.png" width="30%"></img><img src="https://github.com/giomatfois62/rofi-desktop/blob/main/gallery/rofi_quiz.png" width="30%"></img>

## drun Mode
All scripts have an associated *.desktop* file in the *applications* folder, which can be used to show them in rofi's drun mode with all the other installed applications. Run the script *drun.sh* to show a drun menu that also includes all rofi-desktop scripts.  

Custom icons and entry text can be set modifying the *Icon* and *Name* fields in the *.desktop* files. Moreover, additional custom scripts can be integrated easily by placing a new *.desktop* file in the *applications* folder.  

Setting the *DRUN_CATEGORIES* shell variable before running the script will filter entries based on their category. for example:
```
DRUN_CATEGORIES=Rofi ./drun.sh          # shows only rofi-desktop scripts
DRUN_CATEGORIES="Rofi,Game" ./drun.sh   # shows games and rofi-desktop scripts
```

## Custom Menus

Users can easily create custom menus editing the *rofi-desktop.sh* script or by putting simple json files, containing the list of entries with corresponding commands to run and optional icons to show, in the *scripts/menus* folder.  
Visit the [rofi-json](https://github.com/luiscrjunior/rofi-json) repo for details on the syntax to use for custom entries.

## Global Menu
The script *scripts/rofi-hud.py* shows a rofi menu containing the application menu entries of the currently focused window, in a style similar to Ubuntu Unity's HUD or [plasma-hud](https://github.com/Zren/plasma-hud).  

In order for it to work, applications menus first need to be exported via dbus by a special service. The KDE desktop automatically launch such service when the global menu plugin is added to a panel. [vala-panel](https://github.com/rilian-la-te/vala-panel-appmenu) also contains a similar plugin, which can be used with Mate and Xfce panels.  

Alternatively, run the script *scripts/appmenu-service.py* bundled with rofi-desktop, which provides a partial implementation of the service (Note: programs launched before executing the script need to be restarted in order to export their menus).

## Meta/Alt Key Triggers
Most window managers and desktop environments make it impossible or very hard to bind custom keyboard shortcuts using only single modifier keys, like the Meta key or the Alt key.  
These simple shortcuts are very useful to quickly summon the menus of rofi-desktop.  

A nice little utility that can be used to bind the Meta key to a shortcut of choice is [superkey-launch](https://github.com/ryanpcmcquen/superkey-launch), which by default converts Meta key presses to the "Alt+F2" shortcut.  

Alternatively, run the script *scripts/keypress.py* bundled with rofi-desktop. It will listen for single key presses of the Meta key and the Alt key, calling respectively the all-in-one menu *scripts/rofi-desktop.sh -a* and the application menu *scripts/rofi-hud.py*. Edit the script variables *cmd_command* and *alt_command* to change this behaviour.  

## Monitor Hot-Plugging
The script *scripts/x11_device_watcher.sh* can be used to handle external display connections/disconnections.  
When it detects that a display has been disconnected, it will run "xrandr --auto" on the remaining connected output. When a display is connected, it will either execute the script *scripts/rofi-monitor-layout.sh*, to let the user choose the display configuration to apply, or run the last xrandr command saved by *rofi-monitor-layout.sh*.  

## Dependencies
The only mandatory dependency is rofi, but it's easy to convert most of the scripts to use fzf instead.  
Optional dependencies for some of the tools are: 
- jq
- curl
- wget
- xmllint
- mpv
- yt-dlp
- rofi-blocks
- rofi-calc
- bc
- cal
- xrandr
- ffmpeg
- pactl
- paplay
- fd
- ripgrep
- htop
- inxi
- at
- pass
- greenclip/cliphist
- translate-shell
- jsonpickle
- FontAwesome
- sdcv
- xclip/wl-clipboard
- xdotool/ydotool
- playerctl
- python3-xlib
- python3-lxml
- python3-requests
- python3-xcffib
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
- [windwp](https://github.com/windwp/rofi-color-picker)
- [colonelpanic8](https://github.com/colonelpanic8/rofi-systemd)
- [mrHeavenli](https://github.com/mrHeavenli/rofi-playerctl)
- [RafaelBocquet](https://github.com/RafaelBocquet/i3-hud-menu)
- [Bugswriter](https://github.com/Bugswriter/pirokit)
- [wzykubek](https://github.com/wzykubek/rofi-mpd)
- [HarHarLinks](https://github.com/HarHarLinks/wireguard-rofi-waybar)
- [kriansa](https://github.com/kriansa/wmcompanion)
- [xcdkz](https://github.com/xcdkz/YT-Feeder)
- [justchokingaround](https://github.com/justchokingaround/lobster)
- [pystardust](https://github.com/pystardust/ani-cli)
