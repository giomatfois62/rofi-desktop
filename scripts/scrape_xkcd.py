#!/usr/bin/env python3
import requests
from lxml import html
import os
import sys

if (len(sys.argv) > 1):
    filename = sys.argv[1]
else:
    print("no file name provided, fallback to ~/.cache/xkcd")
    filename = os.path.expanduser('~') + "/.cache/xkcd"

url = "https://xkcd.com/archive/"

r = requests.get(url)

tree = html.fromstring(r.content)

comics = tree.xpath('//div[@id="middleContainer"]/a')

with open(filename, 'w') as f:
    f.write("Random\n")

    for ele in comics:
        name = ele.text
        href = ele.attrib['href'].replace("/","")
        f.write("{} {}\n".format(href, name))


