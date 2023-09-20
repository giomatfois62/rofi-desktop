#!/usr/bin/env python3

import os
import psutil
import subprocess
from pynput.keyboard import Key, Listener

script_dir = os.path.dirname(os.path.abspath(__file__))
command = script_dir+"/rofi-desktop.sh -a"

pressed = False

def on_press(key):
	global pressed
	if key == Key.cmd:
		pressed = True
	else:
		pressed = False
		
def on_release(key):
	global pressed

	if key == Key.cmd and pressed:
		pressed = False

		for process in psutil.process_iter():
			if process.name() == 'rofi':
				#process.kill()
				return

		os.system("{} & disown".format(command))

with Listener(on_press=on_press, on_release=on_release) as listener:
	listener.join()
