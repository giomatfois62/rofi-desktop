#!/usr/bin/env python3

import requests
from lxml import html
import sys

if (len(sys.argv) > 1):
    query = sys.argv[1]

    if (len(sys.argv) > 2):
        page = int(sys.argv[2])
    else:
        page = 1
else:
    sys.exit()

base_url = "https://annas-archive.li"

if (page > 1):
    url = base_url + "/search?q=" + query.replace(" ","+") + "&page=" + str(page)
else:
    url = base_url + "/search?q=" + query.replace(" ","+")

r = requests.get(url)
tree = html.fromstring(r.content)

books = tree.xpath('//div[@class="h-[110px] flex flex-col justify-center "]/a')
books_hidden = tree.xpath('//div[@class="h-[110px] flex flex-col justify-center js-scroll-hidden"]')

for b in books_hidden:
    b = ((html.tostring(b, encoding=str)).replace("<!-- ","").replace("-->",""))
    books.append(html.fromstring(b).getchildren()[0])
    
for b in books:
    book_url = base_url + b.attrib['href']
    book_thumb = b.getchildren()[0].getchildren()[0].getchildren()[1].attrib['src']
    book_info = b.getchildren()[1]
    
    full_title = book_info.getchildren()[0].text
    title = book_info.getchildren()[1].text
    publisher = book_info.getchildren()[2].text
    author = book_info.getchildren()[3].text
    
    # more book info (lang, size, type, source)
    book_info_parts = full_title.split(", ")
    
    if (" [" in book_info_parts[0]):
        lang = book_info_parts[0].split(" ")[1]
        file_type = book_info_parts[1]
        file_size = book_info_parts[3]
    else:
        lang = "xx"
        file_type = book_info_parts[0]
        file_size = book_info_parts[2]
    
    if (title is None):
        title = book_info_parts[-1]
    
    if (author is None):
        author = publisher

    line = "{} {} {} {} {} || {}\\x00icon\\x1fthumbnail://{}".format(
        book_url,lang,file_type,file_size,author,title,book_thumb)
    
    print(line)
    

