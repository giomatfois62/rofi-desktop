#!/usr/bin/env python3

import requests
from lxml import html
import sys

if (len(sys.argv) > 1):
    query = sys.argv[1]

    if (len(sys.argv) > 2):
        page = sys.argv[2]
    else:
        page = 1
else:
    sys.exit()

url = "https://bitsearch.to/search?q=" + query.replace(" ","+") + "&page=" + str(page)
r = requests.get(url)
tree = html.fromstring(r.content)

titles = tree.xpath('//h5[@class="title w-100 truncate"]')
stats = tree.xpath('//div[@class="stats"]')
magnets = tree.xpath('//a[@class="dl-magnet"]')

if (len(titles) == 0):
    sys.exit()

for i in range(0, len(titles)):
    entry_num = 20*(int(page) - 1) + i + 1
    entry_title = titles[i].text_content().replace("\n","").replace("⭐","").replace("✅","")
    entry_stats = stats[i].text_content().replace("\n"," ")
    entry_size = stats[i].getchildren()[1].text_content().replace("\n","")
    entry_seeders = stats[i].getchildren()[2].text_content().replace("\n","")
    entry_leechers = stats[i].getchildren()[3].text_content().replace("\n","")
    entry_magnet = magnets[i].attrib['href']

    entry_line = "{} {} - [{}] [S:{}, L:{}] {}".format(
        entry_magnet, entry_num, entry_size, entry_seeders, entry_leechers, entry_title)

    print(entry_line)


