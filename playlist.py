#!/usr/bin/python2

import os
#import random
import sys
import subprocess

pwd = os.getcwd()+"/"
print(":: Looking in "+pwd)
files = os.listdir(pwd)
files.sort()
for i in files:
    if i == "list":
        files.remove(i)
nums = range(1,len(files)+1)

if len(files) >= 1000:
    sys.exit("TOO MANY THINGS!!")
print("")
for i in nums:
    line = " "
    if len(files) >= 100 and i < 10:
        line += "  "
    elif len(files) >= 100 and i < 100:
        line += " "
    elif len(files) >= 10 and i < 10:
        line += " "
    line += str(i)+" | "
    line += files[i-1]
    print(line)
print("")

keys = raw_input("Selections? [1,...,n|p|q]\n>> ")
selfiles = []
selnums = []
play = 0

choice = (keys.split(","))
for i in choice:
    if i == "q":
        sys.exit("Quit")
for i in choice:
    if i == "p":
        play = 1
        choice.remove(i)
for i in choice:
    selnums.append(int(i))
for i in selnums:
    selfiles.append(files[i-1])

playlist = open(pwd+"list","w")
for i in selfiles:
    print >>playlist, i
playlist.close()

if play == 1:
    subprocess.call(["mpv","--playlist=list"])
    subprocess.call(["rm","list"])

print("Done!")
