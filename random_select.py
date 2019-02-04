#!/usr/bin/python2
# random_select.py

import os
import random
import getopt
import sys

#pDir = os.path.dirname(os.path.realpath(__file__))
pDir = os.getcwd()
ask1 = True
ask2 = True
save = ""
isDone = "n"
isFirst = True
listAll = False
help = "Usage: \033[1mrandom_select.py\033[0m [ -n \033[4mnum\033[0m ] [ -P ]\n       \033[1mrandom_select.py\033[0m -h"
numItems = 1

def help():
    print("Usage: \033[1mrandom_select.py\033[0m [ -n \033[4mnum\033[0m ] [ -P ]")
    print("       \033[1mrandom_select.py\033[0m -h")

try:
    opts, args = getopt.getopt(sys.argv[1:],"hn:P")
except getopt.GetoptError:
    help()
    sys.exit(2)
for opt, arg in opts:
    if opt == "-h":
        help()
        exit(0)
    elif opt == "-n":
        numItems = int(arg)
        print("Select "+arg+" items")
    elif opt == "-P":
        listAll = True

while ask1:
    userIn = save+raw_input("Directory?\n>> "+pDir+"/"+save)
    ask2 = True
    tDir = os.path.join(pDir,userIn)
    if isFirst == True or userIn != save or isDone == "z" or isDone == "q" or isDone == "s":
        stuff = os.listdir(tDir)
        stuff.sort()
        isFirst = False
#    numItems = int(raw_input("How many items? Items remaining: "+str(len(stuff))+"\n>> "))
    if numItems > len(stuff):
        numItems = len(stuff)
    print(":: Looking in "+tDir+"...")
    if listAll == True:
        print("---------------")
        for i in stuff:
        	print(i)
        print("---------------")
    print("")
    for i in range(0,numItems):
        a = random.choice(range(0,len(stuff)))
        choice = stuff[a]
        print(" "+choice)
        stuff.remove(stuff[a])
    print("")
    while ask2:
        if numItems == 1:
            isDone = raw_input("Continue? [y,n,q,a,s,z] ("+str(len(stuff))+")\n>> ")
        else:
            isDone = raw_input("Continue? [y,n,q,a,s] ("+str(len(stuff))+")\n>> ")
    	if isDone == "y":
    	    ask2 = False
    	    save = ""
    	elif isDone == "n":
    	    ask2 = False
    	    ask1 = False
        elif isDone == "q":
            ask2 = False
            save = ""
            pathItems = userIn.split("/")
            for i in range(len(pathItems) - 1):
                save = save+pathItems[i]
    	elif isDone == "a":
    	    ask2 = False
    	    save = userIn
        elif isDone == "s":
            ask2 = False
            save = userIn
    	elif isDone == "z":
            if numItems == 1:
       	        ask2 = False
                if userIn == "":
                    save = userIn+choice
                else:
                    save = userIn+"/"+choice
            else:
                print("Invalid.")
    	else:
	    print("Invalid.")
