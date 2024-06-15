#!/usr/bin/env python3

import requests
import json
import time
import random
from subprocess import Popen,PIPE

url="https://opentdb.com/api.php?amount=1"

while (True):
    r = requests.get(url)
    data = r.json()
    
    if (len(data["results"]) <= 0):
        break
    
    category = data["results"][0]["category"]
    question = data["results"][0]["question"]
    correct_ans = data["results"][0]["correct_answer"]
    answers =  data["results"][0]["incorrect_answers"]
    answers.append(correct_ans)
    mesg = "<b>"+category+"</b>" + "\n\n" + question
    
    random.shuffle(answers)
    choices = "\n".join(answers)
    
    p1 = Popen(["echo", choices], stdout=PIPE)
    p2 = Popen(["rofi", "-dmenu", "-mesg", mesg, "-i", "-p", "Answer"], stdin=p1.stdout, stdout=PIPE)
    p1.stdout.close()
    answer = p2.communicate()[0].decode('utf8').rstrip()
    
    if answer.endswith("\n"):
        answer = answer[:-1]
    
    if (len(answer) == 0):
        break

    p2.terminate()
    
    if (answer == correct_ans):
        p2 = Popen(["rofi", "-e", "Correct!"])
    else:
        p2 = Popen(["rofi", "-e", "Wrong!"])
    
    p2.wait()
    
    #with open(f"data{i}.json", 'w') as f:
    #    json.dump(data, f)
