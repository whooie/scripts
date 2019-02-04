#!/usr/bin/python2

import re
import sys
import getopt
import random

def help():
    print("Usage: \033[4mitems\033[0m | \033[1mrandom_select.py\033[0m [ -n \033[4mnum\033[0m ] [ -P ]")
    print("               \033[1mrandom_select.py\033[0m -h")

num_items = 1
list_all = False
pattern = re.compile('(.*:.*)|(^$)', re.IGNORECASE)

try:
    opts, args = getopt.getopt(sys.argv[1:],"hn:P")
except getopt.GetoptError:
    help()
    exit(1)
for opt, arg in opts:
    if opt == "-h":
        help()
        exit(1)
    elif opt == "-n":
        num_items = int(arg)
    elif opt == "-P":
        list_all = True

items = sys.stdin.read().split("\n")
items = filter(lambda x: not pattern.search(x), items)

if list_all:
    print("---------------")
    for item in items:
        print(" "+item)
    print("---------------")

print("")
for num_item in range(min(num_items, len(items))):
    print(" "+items.pop(int(len(items)*random.random())))
print("")
