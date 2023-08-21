#!/usr/bin/env python3
import html
import sys
import os
import subprocess

EDITORS = {
    "vscode": "/usr/bin/code",
    "vscodium": "/usr/bin/vscodium",
    "atom": "/usr/bin/atom",
    "fleet": "~/.local/share/JetBrains/Toolbox/scripts/fleet",
    "emacs": "/usr/bin/emacs",
    "qtcreator": "~/Programs/qtcreator/bin/qtcreator",
}

def generate_directories_list(path: str):
    directories = []

    try: 
        for dirs in os.listdir(path):
            if os.path.isdir(str(path) + "/" + str(dirs)):
                relative_path = str(dirs)
                absolute_path = str(path) + "/" + str(dirs)
                
                directories.append({
                    "name": relative_path,
                    "path": absolute_path
                })
    except FileNotFoundError as e:
        print(f"Directory not found. ({e.strerror}).")
        sys.exit(1)
    except NotADirectoryError as e:
        print(f"Path is not a directory. ({e.strerror}).")
        sys.exit(1)
    except PermissionError as e:
        print(f"Permission denied. ({e.strerror}).")
        sys.exit(1)
    except Exception as e:
        print(f"An error occured. ({e.strerror}).")
        sys.exit(1)
        
    return directories

def init_editor():
    editor = os.environ.get('PROJECTS_EDITOR')

    if editor is None:
        return 'vscode'
    if editor not in EDITORS:
        print(f"Editor not supported. Supported editors: {', '.join(EDITORS.keys())}.")
        sys.exit(1)

    return editor

def init_directory():
    dir_on_env = os.environ.get('PROJECTS_DIRECTORY')
    dir_to_open = os.path.abspath(os.path.expanduser(dir_on_env))
    
    return dir_to_open

def main():
    print(f"\0prompt\x1fProjects")
    ROFI_EDITOR = init_editor()

    search_string = html.unescape((' '.join(sys.argv[1:])).strip())

    init_directory()

    path = init_directory()
    directories = generate_directories_list(path)
    
    for directory in directories:
        print(f"{directory['name']}")
    
    for directory in directories:
        if search_string == directory['name']:
            app_to_open = os.path.abspath(
                os.path.expanduser(EDITORS[ROFI_EDITOR])
            )
            directory_to_open = os.path.abspath(
                os.path.expanduser(directory['path'])
            )

            subprocess.Popen(
                f"{app_to_open} {directory_to_open} & disown",
                shell=True, 
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            ).wait(10000)

            os._exit(0)

if __name__ == "__main__":
    main()
