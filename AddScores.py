import os
import Constants
from datetime import date

def check_file(filename):
    file_exists = os.path.isfile(filename) 
    if not file_exists:
        open(filename, "x")

def print_intro():
    print("--------Here are your possible commands------------")
    print("game: initials1 initials2 score1 score2 initials3 initials4")
    print("q: end session \nnames: get list of player initials ")

def check_valid_game(game):
    s = game.split()

    if len(s) != len(set(s)):
        return "Error: Duplicates in game input"

    if(len(s) > 6):
        return "Error: Entered too many items"

    for i in range(0,6):
        if(i == 2 or i == 3):
            if(not s[i].isdigit):
                return "Error: Entered " + s[i] + " when you were supposed to enter a number"
        else:
            if(not Constants.check_valid_initials(s[i])):
                return "Error: " + s[i] + " is not valid initials"
    return None

def add_scores(filename):
    f = open("scores.txt","a+")

    print_intro()

    while s := input("Enter the game, q or names: ").upper().rstrip():
        if s == 'Q':
            f.close()
            exit(0)

        if s == 'NAMES':
            print(Constants.VALID_PLAYERS)
        else:
            if error := check_valid_game(s):
                print(error)
            else:
                print("Adding game!")
                f.write(s + " " + str(date.today()) + "\n")


check_file(Constants.FILENAME)
add_scores(Constants.FILENAME)

# BR EW 12 7 DB FL
# BR EW 12 8 JZ KP
# BR EW 8 12 EB DB 
# EB DB 12 6 FL JC 
# EB JC 12 10 BR EW
# BR PG 12 6 EB JC
# EW DB 13 11 BR PG
# EB JC 12 4 DB EW
# EB JC 15 13 JZ PG
# EB JZ 14 12 BR DB
# EB JZ 14 16 BR DB
# EB JZ 12 10 BR DB
# EB JZ 12 9 DB JC
# EB JZ 12 14 DB JC 
# JZ KJ 12 7 SC RO
# JZ EW 10 12 EB DB
# LY JC 5 12 EB DB
# JZ LY 10 12 EB DB
# EB DB 12 9 BR EW 
# EB DB 12 7 JC LY
# JZ BR 13 4 EB DB
# BR JZ 12 7 EW LY
# JZ KJ 5 12 RO SC
# BR LY 12 9 EW JZ 
# BR LY 12 7 EW JZ
# BR LY 7 12 DB JC 
# DB JC 9 12 EB JZ