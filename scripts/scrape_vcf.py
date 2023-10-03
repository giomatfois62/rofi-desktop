#!/usr/bin/env python3
import os
import sys
import json

if (len(sys.argv) > 1):
    filename = sys.argv[1]
else:
    sys.exit("provide a vcf file as argument")

all_contacts = []
contact = {"name":"", "num":[], "mail":[]}

with open(filename, 'r') as f:
    for line in f:
        if line.startswith("BEGIN:"):
            contact = {"name":"", "num":[], "mail":[]}
        elif line.startswith("END:"):
            if len(contact["name"]) > 0:
                all_contacts.append(contact)
        elif line.startswith("FN:"):
            contact["name"] = line.split(":")[1].replace("\n","")
        elif line.startswith("TEL;"):
            num = line.split(":")[1].replace("\n","")
            if num not in contact["num"]:
                contact["num"].append(num)
        elif line.startswith("EMAIL;"):
            mail = line.split(":")[1].replace("\n","")
            if mail not in contact["mail"]:
                contact["mail"].append(mail)

filename="all_contacts.json"

if len(all_contacts) > 0:
    with open(filename, 'w') as f:
        f.write(json.dumps(all_contacts, indent=4))
