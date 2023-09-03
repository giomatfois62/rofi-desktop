#!/usr/bin/env python3
import requests
from bs4 import BeautifulSoup

sublist = set()

for i in range(1,35):
	url=f"http://redditlist.com/?page={i}"

	print("scraping", url)

	r = requests.get(url)
	soup = BeautifulSoup(r.text, 'html.parser')
	entries=soup.findAll('div', {'class' : 'listing-item'})

	for entry in entries:
		sub=entry.get('data-target-subreddit')
		if sub not in sublist:
			sublist.add(sub)
		
with open('subreddits', 'w') as f:
    for sub in sublist:
        f.write(f"{sub}\n")
