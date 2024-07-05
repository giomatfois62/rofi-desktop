#!/usr/bin/env python3

import requests
import json
import time
import random
from subprocess import Popen,PIPE

url="https://opentdb.com/api.php?amount=1"
points = 0

def call_rofi(choices, mesg):
    p1 = Popen(["echo", choices], stdout=PIPE)
    p2 = Popen(["rofi", "-kb-screenshot", "Control+Shift+space", "-dmenu", "-mesg", mesg, "-i", "-p", "Answer"], stdin=p1.stdout, stdout=PIPE)
    p1.stdout.close()
    
    answer = p2.communicate()[0].decode('utf8').rstrip()
    
    if answer.endswith("\n"):
        answer = answer[:-1]
    
    p1.terminate()
    p2.terminate()
    
    return answer

while (True):
    r = requests.get(url)
    data = r.json()
    
    if (len(data["results"]) <= 0):
        break
    
    start = time.time()
    
    category = data["results"][0]["category"]
    question = data["results"][0]["question"]
    difficulty = data["results"][0]["difficulty"]
    correct_ans = data["results"][0]["correct_answer"]
    answers =  data["results"][0]["incorrect_answers"]
    answers.append(correct_ans)
    random.shuffle(answers)
    mesg = f"<b>{category}</b>\n\n{question}"
    choices = "\n".join(answers)
    
    answer = call_rofi(choices, mesg)
    
    if (len(answer) == 0):
        break
    
    if (answer == correct_ans):
        if (difficulty == "hard"):
            win = 5
        elif (difficulty == "medium"):
            win = 3
        else:
            win = 1
        
        points += win
        mesg += f"\n\n<b>{answer}</b>\nCorrect! +{win} Points ({points} total)"
    else:
        mesg += f"\n\n<b>{answer}</b>\nWrong! Correct answer: <b>{correct_ans}</b>"
    
    choices = "Play Again\nExit"
    
    answer = call_rofi(choices, mesg)
    
    if (len(answer) == 0 or answer == "Exit"):
        break
    
    end = time.time()
    
    # give time for the api to recharge
    if (end - start < 6):
        time.sleep(int(6 - (end - start)))
