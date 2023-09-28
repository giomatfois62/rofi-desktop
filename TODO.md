# GENERAL
- Implement or facilitate menus translation
- Implement menu history in all scripts
- Add icons to main menus with fontawesome or bundled resources
- Look at code of rofi-systemd and rofi-emoji for examples on custom keybindings
- Show error messages for dependencies not found
- Add more menu instructions using -mesg or placeholders

# ADDITIONS
- Integrate rofi-polkit-agent (needs cmd-polkit project)
- Experiment with alt-tab binding to show window menu (https://github.com/davatorium/rofi/issues/1867)

# ENHANCEMENTS
- Enhance Search (search tags metadata, add tags to files, remove files, preview files)
- Add option to sort search by creation/modification date
- Show context in file contents search
- Optionally show window thumbnails in a grid

# BUGFIX
- Debug rofi-autostart script and make it work reliably
- Fix link extraction for some rss feed providers
- Improve rofi-mpd menu code to avoid bugs with custom keyboard shortcuts

# WAYLAND COMPAT
- clipboard (greenclip)
- rofi-brightness.sh (must use gammastep, ddc, wlr-randr)
- rofi-cheat.sh (xclip)
- rofi-color-picker.sh (xclip)
- rofi-ffmpeg.sh (must use obs or native screen recording utilities)
- rofi-hud.py (need porting away from xlib)
- rofi-keypassxc.sh (xclip)
- rofi-keyboard-layout.sh (must be done by the compositor)
- rofi-monitor-layout.sh (must use wlr-randr, way-displays)
- rofi-screenshot.sh (partially, scrot/xfce-screenshooter are x11 only, should fallback on maim/slurp in wayland)

# COMPLETED
- Make some variables configurable from file (DONE)
- Make thumbnails grid size configurable (DONE)
- Streamline ROFI_CMD variables usage (DONE)
- Add default env variables files with comments (DONE)
- Merge settings menu in main desktop menu and use flags to show (DONE)
- Add default rofi config and themes (DONE)
- Implement a projects module to manage code projects (DONE)
- Integrate a chatgpt or other language model dialog (DONE)
- Replace command outputs tests with "-n" (DONE)
- Use xdg-mime default to set default applications (DONE)
- Document scripts working only in x11 and try to support Wayland where possible (DONE)
- Integrate rofi-color-picker (DONE)
- Integrate rofi-systemd (DONE)
- Test ffmpeg menu for videos output to webm (DONE)
- Make ffmpeg video codec configurable (DONE)
- Implement a dictionary module (DONE)
- Integrate rofi-playerctl (DONE)
- Fix urbandictionary scraping (DONE)
- Fix player selection in rofi-playerctl (DONE)
- Implement or find global menu dbus service (DONE)
- Add exit code 1 to rofi-dev-launcher if nothing is selected (DONE)
- Rewrite rofi-dev-launcher in bash and fix exit code issue (DONE)
- Add more news providers and implement a menu to choose provider (DONE)
- Add random wallpaper option (DONE)
- Add livetv.sx events menu (DONE)
- Add configurable options to rofi-livetv (DONE)
- Move all scripts to script directory (DONE)
- Integrate snippy (paste snippets stored in folder) (DONE)
- Fix rofi-tv json link or convert script to use m3u playlist file (DONE)
- Add a create custom menu module using rofi-json (DONE)
- Make rofi-news easier to configure with external file (DONE)
- Add world clock module (DONE)
- Show current keyboard layout in rofi-keyboard-layout (DONE)
- Improve weather module supporting custom location (DONE)
- Implement changing timezone in world_clocks function or make a separate file (DONE)
- Source the config.env file in the start.sh script (DONE)
- Implement multiple lists of todo files (DONE)
- Add a single mimetype editor to rofi-mime (DONE)
- Implement a wizard to show on first run and ask basic stuff (DONE)
- Fix rofi-mpd current song format breaking markup (DONE)
- Fix rofi-calendar current day format in fedora (DONE)
- Add window menu (DONE)
- Move calendar events, notes, todos to data dir (DONE)

# DISCARDED
- Integrate rofi-monitor.py for better screen management (NO only works in i3wm)
- Integrate rofi-ytm for youtube music with search suggestions (NO needs api key)
- Add option to browse files in grid view with big thumbnails (NO does not display mimetype icons and thumbs)
- Consider rofi-checklist as alternative to rofi-todo.sh (NO too complicated)
- Add option to sort wallpapers by creation/modification date (MAYBE difficult using current implementation)

