#!/usr/bin/env python3
import requests
from lxml import html
import json
import os
import sys

base_url = "https://apollo.rss.com/search/podcasts/itunes-category/"

categories = {
     # arts
    "Books":"2",
    "Design":"3",
    "Fashion and Beauty":"4",
    "Food":"5",
    "Performing Arts":"7",
    "Visual Arts":"8",
    # business
    "Careers":"15",
    "Entrepreneurship":"10",
    "Investing":"16",
    "Management":"11",
    "Marketing":"12",
    "Non-Profit":"13",
    # comedy
    "Comedy Interviews":"20",
    "Improv":"21",
    "Stand-Up":"22",
    # education
    "Courses":"24",
    "How To":"25",
    "Language Learning":"26",
    "Self-Improvement":"27",
    # fiction
    "Comedy Fiction":"34",
    "Drama":"35",
    "Science Fiction":"36",
    # gov
    "Government":"33",
    # health
    "Alternative Health":"51",
    "Fitness":"52",
    "Medicine":"53",
    "Mental Health":"54",
    "Nutrition":"55",
    "Sexuality":"56",
    # history
    "History":"49",
    # kids & family
    "Education for Kids":"63",
    "Parenting":"64",
    "Pets & Animals":"65",
    "Stories for Kids":"66",
    # leisure
    "Animation and Manga":"68",
    "Automotive":"69",
    "Aviation":"70",
    "Crafts":"71",
    "Games":"72",
    "Hobbies":"73",
    "Home and Garden":"74",
    "Video Games":"75",
    # music
    "Music Commentary":"77",
    "Music History":"78",
    "Music Interviews":"79",
    # news
    "Business News":"82",
    "Daily News":"83",
    "Entertainment News":"84",
    "News Commentary":"85",
    "Politics":"86",
    "Sports News":"87",
    "Tech News":"88",
    # religion
    "Buddhism":"90",
    "Christianity":"91",
    "Hinduism":"92",
    "Islam":"93",
    "Judaism":"94",
    "Religion":"151",
    "Spirituality":"96",
    # science
    "Astronomy":"102",
    "Chemistry":"103",
    "Earth Sciences":"104",
    "Life Sciences":"105",
    "Mathematics":"106",
    "Natural Sciences":"107",
    "Nature":"108",
    "Physics":"109",
    "Social Sciences":"110",
    # society & culture
    "Documentary":"112",
    "Personal Journals":"115",
    "Philosophy":"116",
    "Places & Travel":"117",
    "Relationships":"113",
    # sports
    "Baseball":"119",
    "Basketball":"120",
    "Cricket":"121",
    "Fantasy Sports":"122",
    "Football":"123",
    "Golf":"124",
    "Hockey":"125",
    "Rugby":"126",
    "Running":"127",
    "Soccer":"128",
    "Swimming":"129",
    "Tennis":"130",
    "Volleyball":"131",
    "Wilderness":"132",
    "Wrestling":"133",
    # tv & film
    "After Shows":"146",
    "Film History":"147",
    "Film Interviews":"148",
    "Film Reviews":"149",
    "TV Reviews":"150",
    # tech
    "Technology":"139",
    # crime
    "True Crime":"144"
}


all_results = []

for cat in categories:
    print(cat)

    url = base_url+categories[cat]+"?limit=50&page="
    podcasts = []

    for i in range(1,100):
        page_url=url+str(i)
        r = requests.get(page_url)

        # get json
        reply_json = r.json()

        print(i)
        #print(reply_json)
        #print("\n\n\n")

        if (len(reply_json) > 0):
            podcasts = podcasts + reply_json
        else:
            break

    all_results = all_results+podcasts

    filename="podcasts/"+cat+".json"

    if (not os.path.exists(filename)):
        with open(filename, 'w') as f:
            f.write(json.dumps(podcasts, indent=4))

filename="all_podcasts.json"

with open(filename, 'w') as f:
    f.write(json.dumps(all_results, indent=4))
