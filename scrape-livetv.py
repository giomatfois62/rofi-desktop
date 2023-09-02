#!/usr/bin/env python3
import requests
from lxml import html
import json
import os

base_url = "http://livetv.sx"
url = "http://www.livetv.sx/en/allupcoming"
filename = os.path.expanduser('~') + "/.cache/livetv.json"

r = requests.get(url)

# get filtered source code
tree = html.fromstring(r.content)

event_names = tree.xpath('//td[@align="left"]/a[@class="live"]')
event_details = tree.xpath('//td[@align="left"]/span[@class="evdesc"]')
events = list(zip(event_names, event_details))
events_list = []

# print texts in first element in list
for ele in events:
    #print (ele[0].text, " - ", ele[1].text, " (", url+ele[0].get("href"), ")")
    name = ele[0].text.strip()
    desc = str(ele[1].text_content())
    time = desc.split("\r\n\t\t\t\t\t\t\t\t\t\t\t\r\n\t\t\t\t\t\t\t\t\t\t\t")[0]
    category = desc.split("\r\n\t\t\t\t\t\t\t\t\t\t\t\r\n\t\t\t\t\t\t\t\t\t\t\t")[1]
    link = base_url+ele[0].get("href")
    events_list.append({"name":name, "time":time, "category":category, "link":link})

events_list = sorted(events_list, key=lambda k: (k['time'], k['category']))

with open(filename, 'w') as f:
    json.dump(events_list, f)
