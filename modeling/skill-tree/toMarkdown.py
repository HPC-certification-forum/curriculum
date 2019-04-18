#!/usr/bin/env python3
from xml.dom import minidom
import os
import re

def cleanXML(str):
  a = str.firstChild.nodeValue.split("\n")
  b = [x.strip() for x in a]
  return " ".join(b)

def updatePage(dir, name, id):
  with open(dir + "/start.txt", "w") as o:
    o.write("# " + id + "\n")
    o.write("# Name: " + name + "\n")

def updateGraph(dir, name):
  o.write('''
<graphviz neato right>
digraph ATN {
rankdir=LR;
s25[label="25"];

}
</graphviz>''')

def createMarkdown(id, name, defi):
  m = re.match("([A-Z]+)(.*)-(.*)", id)
  if not m:
    return
  group = m.group(1)
  order = m.group(2)
  level = m.group(3)
  if order != "":
    order = order.split(".")
  else:
    order = []
  if group == "ST" or group == "TC":
    return

  directory = "skills/" + group + "/" + "/".join(order)
  directory = directory.lower()
  if not os.path.exists(directory):
    os.makedirs(directory)
    dir = ""
    for sub in directory.split("/"):
      dir = dir + sub + "/"
      if not os.path.exists(dir + "/start.txt"):
        with open(dir + "/start.txt", "w") as o:
          o.write("# " + sub + "\n")

  file = directory + "/" + level + ".txt"
  file = file.lower()
  updatePage(directory, name, group + "-".join(order))
  with open(file, "w") as o:
    o.write("# %s\n" % id)
    o.write("# Name: %s\n" % name)
    o.write("# Background\n")
    for child in defi.getElementsByTagName('ShortBackground'):
      for child2 in child.getElementsByTagName('Item'):
        o.write( "  * " + cleanXML(child2) + "\n")
    o.write("# Learning objectives\n") # http://batchwood.herts.sch.uk/files/Learning-Objectives.pdf
    o.write("# Outcomes\n")
    for child in defi.getElementsByTagName('Description'):
      for child2 in child.getElementsByTagName('Item'):
        o.write( "  * " + cleanXML(child2) + "\n")

map = {}
mydoc = minidom.parse('SkillsBase.xml')
items = mydoc.getElementsByTagName('Skill')
for elem in items:
  map[elem.attributes['Id'].value] = elem.attributes['Name'].value

for elem in items:
  for child in elem.getElementsByTagName('Definition'):
    createMarkdown(elem.attributes['Id'].value, elem.attributes['Name'].value, child)

print(map)
