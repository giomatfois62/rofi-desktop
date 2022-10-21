#!/usr/bin/env python3

######
# rofi-hud
# author: Kasperi Kuuskoski (@sixrapid)
# adapted from zren/plasma-hud and ixxra/HUD.py on github
# tested with rofi 1.5.4 and python 3.8.2 on Arch Linux
#######

import gi
gi.require_version("Gtk", "3.0")

import dbus
import dbus.service
import logging
import subprocess
import time
from Xlib import display, protocol, X, Xatom, error
from collections import OrderedDict

logging.disable('DEBUG')

### constants
NOBREAKSPACE = '\u00A0'
EMSPACE = '\u2003'
PATHARROW = '\u00BB'
PATHSEPARATOR = EMSPACE + PATHARROW + EMSPACE
DEFAULT_SHORTCUT_FG_COLOR = '#888888'


### globals
rofi_process = None
show_icons = True       # Requires rofi 1.5.3
show_shortcuts = True   # Requires rofi 1.5.5?
shortcut_fg_color = DEFAULT_SHORTCUT_FG_COLOR


### general purpose functions and classes
class EWMH:
    # This class provides the ability to get and set properties defined
    # by the EWMH spec. It was blanty ripped out of pyewmh
    # https://github.com/parkouss/pyewmh

    def __init__(self, _display=None, root = None):
        self.display = _display or display.Display()
        self.root = root or self.display.screen().root

    def getActiveWindow(self):
        # Get the current active (toplevel) window or None (property _NET_ACTIVE_WINDOW)
        active_window = self._getProperty('_NET_ACTIVE_WINDOW')
        if active_window == None:
            return None

        return self._createWindow(active_window[0])

    def _getProperty(self, _type, win=None):
        if not win:
            win = self.root
        atom = win.get_full_property(self.display.get_atom(_type), X.AnyPropertyType)
        if atom:
            return atom.value

    def _createWindow(self, wId):
        if not wId:
            return None
        return self.display.create_resource_object('window', wId)

def format_path(path):
    # format the menu items (paths) to a human-readable format
    #logging.debug('Path:%s', path)
    result = path.replace(PATHSEPARATOR, '', 1)
    result = result.replace('Root' + PATHSEPARATOR, '')
    result = result.replace('Label Empty' + PATHSEPARATOR, '')
    result = result.replace('_', '')
    return result

def convert_alphanumeric_to_unicode(text):
    out = ''
    for c in text:
        if c.isnumeric():
            c = chr(ord(c) + 120764) #convert numbers
        elif c.islower():
            c = chr(ord(c) + 120205) #convert lowercase
        elif c.isupper():
            c = chr(ord(c) + 120211) #convert uppercase
        else:
            pass

        out += c

    return out

def format_shortcut(text):
    # GTK
    text = text.replace('<Primary>', 'Ctrl+')
    text = text.replace('<Shift>', 'Shift+')
    text = text.replace('<Alt>', 'Alt+')
    text = text.replace('<Mod4>', 'Meta+')
    text = text.replace('bracketleft', '[')
    text = text.replace('bracketright', ']')
    text = text.replace('backslash', '\\')
    text = text.replace('slash', '/')
    text = text.replace('Return', '⏎')

    # Qt
    text = text.replace('Control+', 'Ctrl+')

    # Prevent shortcut from showing up in search
    text = convert_alphanumeric_to_unicode(text)
    text = text.replace('+', '＋') # Full-width Plus (U+FF0B)

    # Add Color.
    # Make sure font is not monospace, which clips the Sans Serif characters.
    #text = '<span fgcolor="' + shortcut_fg_color + '" face="Sans Serif">' + text + '</span>'
    return text

def format_menuitem_label(path, shortcut):
    result = format_path(path)

    if show_shortcuts and shortcut:
        shortcut = format_shortcut(shortcut)
        result += EMSPACE + shortcut

    return result

def format_menuitem(formattedlabel, icon_name):
    result = formattedlabel

    if show_icons and icon_name:
        # Documented at:
        # https://github.com/davatorium/rofi/issues/840#issuecomment-410683206
        result += ' \x00icon\x1f' + icon_name

    # print('\t', result)
    return result


### functions for communicating with rofi
def init_rofi():
    # Init rofi_procss so it starts capturing keystrokes while we slowly pipe in the dbus menu items.
    global rofi_process
    rofi_process = subprocess.Popen(['rofi', '-dmenu', '-i', '-p', 'HUD'],
                                    stdout=subprocess.PIPE, stdin=subprocess.PIPE)

def write_menuitem(menu_item):
    # write menu item to rofi via stdin
    global rofi_process
    menu_string = menu_item + '\n'
    rofi_process.stdin.write(menu_string.encode('utf-8'))
    rofi_process.stdin.flush()

def get_menu():
    # get the menu item user selected from rofi
    global rofi_process, shortcut_fg_color

    if not rofi_process and rofi_process.poll() is not None:
        logging.debug("get_menu() rofi_process was terminated before asking for menu_result")
        return ''

    menu_result = rofi_process.communicate()[0].decode('utf8').rstrip()
    rofi_process.stdin.close()

    return menu_result


### functions for communicating with menu interfaces
def try_dbusmenu_interface(window_id):
    # Get Appmenu Registrar DBus interface
    session_bus = dbus.SessionBus()
    appmenu_registrar_object = session_bus.get_object('com.canonical.AppMenu.Registrar', '/com/canonical/AppMenu/Registrar')
    appmenu_registrar_object_iface = dbus.Interface(appmenu_registrar_object, 'com.canonical.AppMenu.Registrar')

    # Get dbusmenu object path
    try:
        dbusmenu_bus, dbusmenu_object_path = appmenu_registrar_object_iface.GetMenuForWindow(window_id)
    except dbus.exceptions.DBusException:
        return

    # Access dbusmenu items
    try:
        dbusmenu_object = session_bus.get_object(dbusmenu_bus, dbusmenu_object_path)
        logging.debug(dbusmenu_bus)
        dbusmenu_object_iface = dbus.Interface(dbusmenu_object, 'com.canonical.dbusmenu')
    except ValueError:
        logging.info('Unable to access dbusmenu items.')
        return False

    # Valid menu, so init rofi process to capture keypresses.
    init_rofi()

    def get_layout(parent_id = 0, recursion_depth = -1, property_names = ["label", "children-display"]):
        # Returns a layout as a list of items. Each item is an array of [item_id, item_props, item_children].
        _, layout = dbusmenu_object_iface.GetLayout(parent_id, recursion_depth, property_names)
        return layout

    dbusmenu_root_item = get_layout()
    dbusmenu_label_dict = dict()
    dbusmenu_iconlabel_dict = dict()

    # For excluding items which have no action
    blacklist = []

    # expand nested dbus menu
    def explore_dbus_menu(item, path):
        item_id = item[0]
        item_props = item[1]
        item_children = item[2]

        if 'label' in item_props and item_props['label']:
            new_path = path + PATHSEPARATOR + item_props['label']
        else:
            new_path = path

        icon_name = None
        shortcut = None

        if 'icon-name' in item_props and item_props['icon-name']:
            icon_name = str(item_props['icon-name'])
        #logging.debug('icon_name %s', icon_name)

        if 'shortcut' in item_props and item_props['shortcut']:
            shortcut = '+'.join(item_props['shortcut'][0])
        #logging.debug('shortcut %s', shortcut)

        if 'children-display' in item_props:
            if 'canonical' in dbusmenu_object_path: # expand firefox
                dbusmenu_object_iface.Event(item_id, "opened", "not used", 0)

            if not item_children:
                dbusmenu_object_iface.AboutToShow(item_id)
                item_children = get_layout(item_id)[2]

            blacklist.append(new_path)

            #logging.debug('get_layout.child : %s', str(time.perf_counter()))

            # if not rofi_process and rofi_process.poll() is not None:
            #     logging.debug("explore_dbus_menu(child) rofi_process was terminated before child menuitems were piped")
            #     return

            for child in item_children:
                for child_entry in explore_dbus_menu(child, new_path):
                    yield child_entry
        else:
            if new_path not in blacklist:
                item_label = format_menuitem_label(new_path, shortcut)
                dbusmenu_label_dict[item_label] = item_id

                # Icon name is stripped from the menu_result. So we need
                # 2 dicts, one for passing into rofi, and another to parse
                # the result.
                item_entry = format_menuitem(item_label, icon_name)
                dbusmenu_iconlabel_dict[item_entry] = item_id
                # logging.debug('item_entry: #%s: "%s"', str(len(dbusmenu_iconlabel_dict)), str(item_entry))

                yield item_entry

    if not rofi_process and rofi_process.poll() is not None:
        logging.debug("explore_dbus_menu(root) rofi_process was terminated before nested menuitems were piped")
        return False

    for item_entry in explore_dbus_menu(dbusmenu_root_item, ""):
        write_menuitem(item_entry)

    menu_result = get_menu()
    logging.debug('menu_result: "%s"', str(menu_result))

    if menu_result.endswith("\n"):
        menu_result = menu_result[:-1]

    # Use menu result
    if menu_result in dbusmenu_label_dict:
        action = dbusmenu_label_dict[menu_result]
        logging.debug('AppMenu Action : %s', str(action))
        dbusmenu_object_iface.Event(action, 'clicked', 0, 0)

    # Firefox:
    # Send closed events to level 1 items to make sure nothing weird happens
    # Firefox will close the submenu items (luckily!)
    # VimFx extension wont work without this
    dbusmenu_level1_items = dbusmenu_object_iface.GetLayout(0, 1, ["label"])[1]
    for item in dbusmenu_level1_items[2]:
        item_id = item[0]
        dbusmenu_object_iface.Event(item_id, "closed", "not used", dbus.UInt32(time.time()))

    return True

def try_gtk_interface(gtk_bus_name, gtk_menu_object_path, gtk_actions_paths_list):

    # get menus
    session_bus = dbus.SessionBus()
    gtk_menu_object = session_bus.get_object(gtk_bus_name, gtk_menu_object_path)
    gtk_menu_menus_iface = dbus.Interface(gtk_menu_object, dbus_interface='org.gtk.Menus')

    # valid menus - init rofi
    init_rofi()

    # dictionaries for menuitems
    gtk_menubar_action_dict = dict()
    gtk_menubar_action_target_dict = dict()

    # DFS search (?) for the menu.
    visited = []     # nodes we have visited
    stack = []       # nodes we want to visit

    stack.append([0, None, ""]) # push the root to the stack

    while stack:
        node = stack.pop()
        node_id, node_path = [node[i] for i in (0, 2)]

        logging.debug("element: %s \n", gtk_menu_menus_iface.Start([0]))

        if node_id not in visited:
            visited.append(node_id)

            # get an array of the menus defined within the group with id "node_id"
            menus = gtk_menu_menus_iface.Start([node_id])

            for menu in menus:
                # each element of the array is a tuple, where [0] is the id of the parent,
                # [1] is the id of the menu itself, and [2] is an array of menu items
                items = menu[2]

                for item in items:
                    # each item is a dictionary of attributes

                    # if the item includes a label attribute, we add the label to the path.
                    if "label" in item:
                        item_label = item["label"]
                        item_path = node_path + PATHSEPARATOR + item["label"]
                    else:
                        item_label = None
                        item_path = node_path

                    # sections and submenus are added to the stack while actions are added to the menuitem dictionary
                    if ":submenu" in item:
                        stack.append([item[":submenu"][0], item_label, item_path])
                    if ":section" in item and item[':section'][0] != node[0] and item['section'][0] not in visited:
                        stack.append([item["section"][0], item_label, item_path])
                    if "action" in item:
                        menu_action = str(item['action']).split(".",1)[1]
                        action_path = format_path(item_path)
                        gtk_menubar_action_dict[action_path] = menu_action
                        if "target" in item:
                            gtk_menubar_action_target_dict[action_path] = item['target']


    # the menu order is messed up right now - fix this
    # for now, this fix at least puts the top-level order correct
    # i.e file - edit - ... - help
    menuKeys = reversed(list(gtk_menubar_action_dict.keys()))

    # tell gmenu we done here
    gtk_menu_menus_iface.End(visited)

    # show user the menu
    if not rofi_process and rofi_process.poll() is not None:
        logging.debug("explore_dbus_menu(root) rofi_process was terminated before nested menuitems were piped")
        return False

    for menuKey in menuKeys:
        write_menuitem(menuKey)

    # check what user chose
    menu_result = get_menu()
    logging.debug('menu_result: "%s"', str(menu_result))

    if menu_result.endswith("\n"):
        menu_result = menu_result[:-1]

    # let application know which menu item was chosen
    session_bus = dbus.SessionBus()
    if menu_result in gtk_menubar_action_dict:
        action = gtk_menubar_action_dict[menu_result]
        target = []
        try:
            target = gtk_menubar_action_target_dict[menu_result]
            if (not isinstance(target, list)):
                target = [target]
        except:
            pass

        for action_path in gtk_actions_paths_list:
            try:
                action_object = session_bus.get_object(gtk_bus_name, action_path)
                action_iface = dbus.Interface(action_object, dbus_interface='org.gtk.Actions')
                not_use_platform_data = dict()
                not_use_platform_data["not used"] = "not used"
                action_iface.Activate(action, target, not_use_platform_data)
            except Exception as e:
                print ("____________________________________________________")
                print (action_path)
                print (str(e))


### Main
def main():
    # Get Window properties and GTK MenuModel Bus name
    ewmh = EWMH()
    win = ewmh.getActiveWindow()
    if win is None:
        logging.debug('ewmh.getActiveWindow returned None, giving up')
        return
    window_id = hex(ewmh._getProperty('_NET_ACTIVE_WINDOW')[0])

    def get_prop_str(propKey):
        value = ewmh._getProperty(propKey, win)
        if isinstance(value, bytes):
            return value.decode("utf8")
        else:
            return value

    #window_pid = get_prop_str('_NET_WM_PID')
    gtk_bus_name = get_prop_str('_GTK_UNIQUE_BUS_NAME')
    gtk_menubar_object_path = get_prop_str('_GTK_MENUBAR_OBJECT_PATH')
    gtk_app_object_path = get_prop_str('_GTK_APPLICATION_OBJECT_PATH')
    gtk_win_object_path = get_prop_str('_GTK_WINDOW_OBJECT_PATH')
    gtk_unity_object_path = get_prop_str('_UNITY_OBJECT_PATH')

    logging.debug('Window id is : %s', int(window_id, 16))
    logging.debug('_GTK_UNIQUE_BUS_NAME: %s', gtk_bus_name)
    logging.debug('_GTK_MENUBAR_OBJECT_PATH: %s', gtk_menubar_object_path)
    logging.debug('_GTK_APPLICATION_OBJECT_PATH: %s', gtk_app_object_path)
    logging.debug('_GTK_WINDOW_OBJECT_PATH: %s', gtk_win_object_path)
    logging.debug('_UNITY_OBJECT_PATH: %s', gtk_unity_object_path)

    if (not gtk_bus_name) or (not gtk_menubar_object_path):
        try_dbusmenu_interface(int(window_id, 16))
    else:
        # Many apps do not respect menu action groups (libreoffice, gnome-mpv) thus we have to include all action groups
        # And many other apps have these properties point to the same path (Sigh!), so we need to remove them!
        gtk_actions_paths_list = [gtk_win_object_path, gtk_menubar_object_path, gtk_app_object_path, gtk_unity_object_path]
        gtk_actions_paths_list = list(set(gtk_actions_paths_list))
        try_gtk_interface(gtk_bus_name, gtk_menubar_object_path, gtk_actions_paths_list)

if __name__ == '__main__':
    #logging.basicConfig(filename="hud.log", level=logging.DEBUG)
    main()
