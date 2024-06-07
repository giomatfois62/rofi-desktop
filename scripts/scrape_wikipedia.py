#!/usr/bin/env python3

import requests
from lxml import html
import sys

all_entries = []
count = 1

def scrape_page(page_url):
    global count
    print(count, "scraping", page_url)
    count = count + 1
    
    r = requests.get(page_url)
    tree = html.fromstring(r.content)
    
    entries = tree.xpath('//a[@class="mw-redirect"]')
    nextbtm = tree.xpath('//a[@title="Special:AllPages"]')

    #global all_entries
    #all_entries += [{"title":entry.text, "link":entry.get("href")} for entry in entries]
    
    with open("data/wikipedia.txt", "a") as myfile:
        for entry in entries:
            myfile.write(entry.text + " " + entry.get("href") + "\n")

    
    if (len(nextbtm) > 0):
        if (len(nextbtm) > 2):
            return nextbtm[1].get("href")
        else:
            return nextbtm[0].get("href")
    else:
        return None

url = "https://en.wikipedia.org/wiki/Special:AllPages"
next_url = scrape_page(url)

while (next_url):
    url = "https://en.wikipedia.org"+next_url
    next_url = scrape_page(url)
    
