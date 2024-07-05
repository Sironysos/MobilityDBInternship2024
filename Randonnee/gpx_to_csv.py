import sys
import xml.parsers.expat

stack = []
def start_element(name, attrs):
	stack.append(name)
	if name == 'gpx' :
		print("lon,lat,time")
	if name == 'trkpt' :
		print("{},{},".format(attrs['lon'], attrs['lat']), end="")

def end_element(name):
	stack.pop()

def char_data(data):
	if stack[-1] == "time" and stack[-2] == "trkpt" :
		print(data)

p = xml.parsers.expat.ParserCreate()

p.StartElementHandler = start_element
p.EndElementHandler = end_element
p.CharacterDataHandler = char_data

p.ParseFile(sys.stdin.buffer)