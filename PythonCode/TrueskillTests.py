from trueskill import Rating, rate
import Constants
from termcolor import colored
import math

# r1 = Rating()
# r2 = Rating()

# r3 = Rating()
# r4 = Rating()

# (new_r1, new_r2), (new_r3, new_r4) = rate([[r1, r2], [r3,r4]])

# (new_r1, new_r3), (new_r3, new_r4) = rate([[new_r1, new_r3], [new_r2, new_r4]])

# print(new_r1)
# print(new_r3)
# print(new_r4)


player_scores = dict()
for player in Constants.VALID_PLAYERS.keys():
    player_scores.update({player: [Rating(), 0, 0, []]})


def get_games():
    f = open(Constants.FILENAME, "r")
    games = []
    for line in f.readlines():
        if line := line.rstrip():
            games.append(line.split())
    f.close()
    return games    

def add_game_to_dict(players, scores):
    ratings = rate([[player_scores[players[0]][0], player_scores[players[1]][0]], [player_scores[players[2]][0], player_scores[players[3]][0]]])

    for i in range(0,2):
        player_scores[players[i]][3].append([Constants.VALID_PLAYERS[players[0]],Constants.VALID_PLAYERS[players[1]], Constants.VALID_PLAYERS[players[2]], Constants.VALID_PLAYERS[players[3]], scores[0], scores[1], ratings[0][i].mu - player_scores[players[i]][0].mu])
        player_scores[players[i]][0] = ratings[0][i]
        player_scores[players[i]][1] = player_scores[players[i]][1] + 1

    for i in range(2,4):
        player_scores[players[i]][3].append([Constants.VALID_PLAYERS[players[0]],Constants.VALID_PLAYERS[players[1]], Constants.VALID_PLAYERS[players[2]], Constants.VALID_PLAYERS[players[3]], scores[0], scores[1], ratings[1][i-2].mu - player_scores[players[i]][0].mu])
        player_scores[players[i]][0] = ratings[1][i-2]
        player_scores[players[i]][2] = player_scores[players[i]][2] + 1

def run_algo(games):
    for game in games:
        if(int(game[2]) > int(game[3])):
            add_game_to_dict([game[0],game[1],game[4],game[5]], [int(game[2]), int(game[3])])
        else:
            add_game_to_dict([game[4],game[5],game[0],game[1]], [int(game[3]), int(game[2])])


def calculate_scores():
    games = get_games()
    run_algo(games)

def takeSecond(elem):
    return elem[1]

def show_scores(player_scores):
    title = "{:-^40s}".format("SCORES")
    print("\n"+title)
    l = []
    for key in player_scores:
        l.append([key, player_scores[key][0].mu, player_scores[key][1], player_scores[key][2]])
    l.sort(key = takeSecond, reverse = True)
    for i in range(0,len(l)):
        print("{:<2} ({:<2},{:>2}) {:20}".format(i + 1, l[i][2], l[i][3], Constants.VALID_PLAYERS[l[i][0]]), end = " ")
        print(colored("{0:3.2f}".format(l[i][1]), 'green'))
    print("-"*len(title)+"\n")
    

calculate_scores()
show_scores(player_scores)

while s := input("For a score breakdown per person, enter their initials. To see scores again, enter s. To quit, enter q: ").upper():
    if(s == 'Q'):
        exit(0)
    elif(Constants.check_valid_initials(s)):
        name = Constants.VALID_PLAYERS[s].upper()
        title = "\n{:-^92s}".format(name)
        print(title)
        for g in player_scores[s][3]:
            print("{:<18} {:>18}  {:<2} - {:>2}  {:<18} {:>18}".format(g[0], g[1], g[4], g[5], g[2],g[3]) , end = " ")
            score_change = round(g[6], 2)
            if(g[6] >= 0):
                print(colored(score_change, 'green'))
            else:
                print(colored(score_change, 'red'))
        print("-"*len(title)+"\n")
    elif s == 'S':
        show_scores(player_scores)
    else:
        print("Invalid entry")
