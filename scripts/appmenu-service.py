#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop

class i3AppmenuService(dbus.service.Object):
  def __init__(self):
    bus_name = dbus.service.BusName('com.canonical.AppMenu.Registrar', bus = dbus.SessionBus())
    dbus.service.Object.__init__(self, bus_name, '/com/canonical/AppMenu/Registrar')
    self.window_dict = dict()

  @dbus.service.method('com.canonical.AppMenu.Registrar',
    in_signature='uo',
    sender_keyword='sender')
  def RegisterWindow(self, windowId, menuObjectPath, sender):
    self.window_dict[windowId] = (sender, menuObjectPath)

  @dbus.service.method('com.canonical.AppMenu.Registrar',
    in_signature='u',
    out_signature='so')
  def GetMenuForWindow(self, windowId):
    if windowId in self.window_dict:
      sender, menuObjectPath = self.window_dict[windowId]
      return [dbus.String(sender), dbus.ObjectPath(menuObjectPath)]

  @dbus.service.method('com.canonical.AppMenu.Registrar')
  def Q(self):
    Gtk.main_quit()

DBusGMainLoop(set_as_default=True)
myservice = i3AppmenuService()
Gtk.main()

# GTK apps : get dbus service (xprop)
