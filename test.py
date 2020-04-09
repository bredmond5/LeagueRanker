import os

filename = "test.txt"
file_exists = os.path.isfile(filename) 
if not file_exists:
    open(filename, "x")

f = open("test.txt","a+")

while True:
    f.write(input("Write a test: "))