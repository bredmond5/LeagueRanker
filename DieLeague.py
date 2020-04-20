import math
import Constants
import numpy as np

def get_game_score(s1, s2):
    s1 = int(s1)
    s2 = int(s2)
    if(s1 < s2):
        tmp = s1
        s1 = s2
        s2 = tmp
    return s1, s2

def get_rating_differential(game):
    winning_score, losing_score = get_game_score(game[2], game[3])
    r = losing_score/(winning_score - 1)
    numerator = 475 * math.sin(min(1, (1 - r) / .5) * .4*math.pi)
    denominator = math.sin(.4*math.pi)
    return 125 + numerator/denominator, winning_score == int(game[2])

def change_player_scores(game):
    rating_differential, team_1_won = get_rating_differential(game)

    team_1_average_score = (player_scores[game[0]][0] + player_scores[game[1]][0]) / 2
    team_2_average_score = (player_scores[game[4]][0] + player_scores[game[5]][0]) / 2
    
    t1_add = team_2_average_score
    t2_add = team_1_average_score

    if team_1_won:
        t2_add -= rating_differential
        t1_add += rating_differential
    else:
        t2_add += rating_differential
        t1_add -= rating_differential
    
    add = t1_add
    for i in range(0,6):
        if(i != 2 and i != 3):
            item = player_scores[game[i]]
            item[1].append(add)
        else:
            add = t2_add


def get_games():
    f = open(Constants.FILENAME, "r")
    games = []
    for line in f.readlines():
        if line := line.rstrip():
            games.append(line)
    f.close()
    return games    

def calculate_scores(player_scores):
    print("Calculating scores...")

    games = get_games()
    n_iters = 10000
    for _ in range(0, n_iters):            
        for game in games:
            change_player_scores(game.split())
        for player in player_scores:
            item = player_scores[player]
            average = 0
            if(len(player_scores[player][1]) > 4):
                average = np.mean(player_scores[player][1])
            item[0] = average
            player_scores[player][1] = []

            
def show_scores(player_scores):
    print("Here are the scores: ")
    for key in player_scores:
        print(Constants.VALID_PLAYERS[key], ":", player_scores[key][0])

player_scores = dict()
for player in Constants.VALID_PLAYERS.keys():
    player_scores.update({player: [1000, []]})

calculate_scores(player_scores)
show_scores(player_scores)

while s := input("For a score breakdown per person, enter their initials. To quit, enter q: ").upper():
    if(s == 'Q'):
        exit(0)
    if(Constants.check_valid_initials(s)):
        print(s)
    else:
        print("Invalid entry")


