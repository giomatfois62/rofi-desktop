## rofi-desktop

rofi-desktop is a collection of scripts launching interactive [rofi](https://github.com/davatorium/rofi) menus, aiming to provide the functionalities of a complete desktop environment. 

The main menu is accessed with *rofi-desktop.sh*, together with a comprehensive system settings menu and a menu of simple utilities. This script supports an optional argument to determine which enties to show:
```
./rofi-desktop -d # shows main menu entries
./rofi-desktop -c # shows custom user menus
./rofi-desktop -s # shows file search menu
./rofi-desktop -s # shows settings menu
./rofi-desktop -u # shows utilities menu
./rofi-desktop -w # shows web search menu
./rofi-desktop -a # shows all the menu entries
```

The *config/config.env* file contains the scripts' variables that can be customized by the user. Source this file somewhere (like in ~/.bashrc) to override their default values.

Users can easily create custom menus editing the *rofi-desktop.sh* script or by putting simple json files in the *scripts/menus* folder.  
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
  - Color Picker (rofi-color-picker.sh)
  - ChatGPT (rofi-gpt.sh)
  - Dictionary (rofi-dict.sh)
  - Media Player (rofi-playerctl.sh)
  - Translate Text (rofi-translate.sh, uses translate-shell)
  - Notepad (rofi-notes.sh)
  - To-Do List (rofi-todo.sh)
  - Set Timer (rofi-timer.sh)
  - Pomodoro Timer (pomo)
  - Characters (rofi-characters.sh, utf-8 char and emoji picker)
  - Take Screenshot (rofi-screenshot.sh, autodetects and uses various screenshot programs)
  - Record Audio/Video (rofi-ffmpeg.sh)
  - SSH Sessions(ssh modi)
  - Snippets (snippy)
  - Code Projects (rofi-projects.sh, browse code projects directory and open projects with preferred editor)
  - Tmux Sessions (rofi-tmux.sh)
  - Password Manager (rofi-passmenu.sh)
  - Clipboard (uses greenclip)
  - Notifications (uses rofication-daemon.py and rofication-gui.py)
  - Task Manager (launch htop or pipe it's output to rofi if modi blocks is available)
- System Settings
  - Appearance (Qt, GTK, rofi style and wallpaper setter with big thumbnails)
  - Network (networkmanager_dmenu.sh)
  - Bluetooth (rofi-bluetooth.sh)
  - Display (rofi-monitor-layout.sh)
  - Default Applications (rofi-mime.sh, set audio/video/images/PDF viewers and file manager)
  - Autostart Applications (rofi-autostart.sh, manage xdg/autostart desktop files)
  - Keyboard Layout (rofi-keyboard-layout.sh)
  - Brightness (rofi-brightness.sh, uses xbacklight)
  - Volume (rofi-volume.sh, uses pactl and pavucontrol)
  - Menu Configuration (edit all rofi-desktop scripts)
  - Language (rofi-locale.sh, set LC_ALL for user session)
  - Systemd Configuration (rofi-systemd.sh)
  - Update System (update-system.sh)
  - System Info (inxi piped to rofi)
  - Install Programs (rofi-flathub.sh)
  - Rofi Shortcuts (keys modi)
- Session Menu (uses loginctl and optional custom lock command)
  - Lock Screen, Log Out, Suspend, Reboot, Shutdown, Hibernate

[gif of the menus](https://github.com/giomatfois62/rofi-desktop/blob/main/demo.webm)

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
