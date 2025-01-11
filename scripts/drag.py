#!/usr/bin/env python3

# https://raw.githubusercontent.com/rkevin-arch/CLIdrag/master/drag.py

import sys
import os
import signal
from PyQt5.QtCore import Qt, QUrl, QMimeData
from PyQt5.QtWidgets import QApplication, QLabel
from PyQt5.QtGui import QDrag

class MainWindow(QLabel):
    def __init__(self, l):
        super().__init__()
        mimedata = QMimeData()
        mimedata.setUrls([QUrl.fromLocalFile(os.path.abspath(fn)) for fn in l])
        qdrag = QDrag(self)
        qdrag.setMimeData(mimedata)
        qdrag.exec(Qt.DropAction.MoveAction)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: %s FILENAME [FILENAME ...]"%sys.argv[0])
        print("Initiates a drag operation as if you're dragging a file / multiple files.")
        print("Click in the window you want to drag the files to.")
        sys.exit()
    app = QApplication(sys.argv)
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    window = MainWindow(sys.argv[1:])

