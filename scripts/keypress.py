#!/usr/bin/env python3

import os
import sys
import signal
import psutil
import subprocess
from pynput.keyboard import Key, Listener

script_dir = os.path.dirname(os.path.abspath(__file__))

cmd_command = script_dir+"/rofi-desktop.sh -a"
alt_command = script_dir+"/rofi-hud.py"

cmd_pressed = False
alt_pressed = False

def exit_script(signal, frame):
	sys.exit()

def on_press(key):
	global cmd_pressed
	global alt_pressed

	cmd_pressed = key == Key.cmd
	alt_pressed = key == Key.alt

def rofi_running():
	for process in psutil.process_iter():
			if process.name() == 'rofi':
				#process.kill()
				return True

	return False
		
def on_release(key):
	global cmd_pressed
	global alt_pressed

	if key == Key.cmd and cmd_pressed:
		cmd_pressed = False

		if (rofi_running()):
			return

		os.system("{} & disown".format(cmd_command))

	if key == Key.alt and alt_pressed:
		alt_pressed = False

		if (rofi_running()):
			return

		os.system("{} & disown".format(alt_command))

if __name__ == '__main__':
	with Listener(on_press=on_press, on_release=on_release) as listener:
		signal.signal(signal.SIGINT, exit_script)
		signal.signal(signal.SIGTERM, exit_script)
		
		listener.join()
