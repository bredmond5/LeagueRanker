import math
import Constants
import numpy as np

player_scores = dict()
for player in Constants.VALID_PLAYERS.keys():
    player_scores.update({player: [1000, 0, []]})

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
    r = losing_score/(winning_score - 2)
    numerator = 475 * math.sin(min(1, (1 - r) / .5) * .4*math.pi)
    denominator = math.sin(.4*math.pi)
    return 125 + numerator/denominator, winning_score == int(game[2])

def add_game_score(game):
    rating_differential, team_1_won = get_rating_differential(game)

    p_s = []        
    p_s.append(player_scores[game[0]])
    p_s.append(player_scores[game[1]])
    p_s.append(player_scores[game[4]])
    p_s.append(player_scores[game[5]])
    
    team_1_average_score = (p_s[0][0] + p_s[1][0]) / 2
    team_2_average_score = (p_s[2][0] + p_s[3][0]) / 2

    team_1_game_score = team_2_average_score
    team_2_game_score = team_1_average_score

    if team_1_won:
        team_1_game_score += rating_differential
        team_2_game_score -= rating_differential
        
    else:
        team_1_game_score -= rating_differential
        team_2_game_score += rating_differential

    total_scores = []
    # Multiply the player score before * amt of games - 1 to account for this game not being in the average
    for i in range(0,4):
        total_scores.append(p_s[i][0]*(p_s[i][1]-1)) 
    # print("player 1 avg and num games: ", p_s[0][0], p_s[0][1])
    # print("player 2 avg and num games: ", p_s[1][0], p_s[1][1])

    player_changes = []
    game_score = team_1_game_score
    # add new game score to total score, divide by number of games, subtract old average to get the difference.
    for i in range(0,4):
        if i == 2:
            game_score = team_2_game_score
        player_changes.append((total_scores[i]+game_score)/p_s[i][1] - p_s[i][0]) 
    # print("player changes for 1 and 2: ", player_changes[0], player_changes[1])
    
    # Get the average changes between the players
    avg_change_1 = (player_changes[0] + player_changes[1])/2
    avg_change_2 = (player_changes[2] + player_changes[3])/2

    # Score to add = old_score + average change between you and teammate multiplied by games played minus the total_score without the game
    # print("player 1: ", (p_s[0][0] + avg_change_1) * p_s[0][1] - total_scores[0])
    # print("player 2: ", (p_s[1][0] + avg_change_1) * p_s[1][1] - total_scores[1])

    player_scores[game[0]][2].append((p_s[0][0] + avg_change_1) * p_s[0][1] - total_scores[0])      
    player_scores[game[1]][2].append((p_s[1][0] + avg_change_1) * p_s[1][1] - total_scores[1])

    player_scores[game[4]][2].append((p_s[2][0] + avg_change_2) * p_s[2][1] - total_scores[2])
    player_scores[game[5]][2].append((p_s[3][0] + avg_change_2) * p_s[3][1] - total_scores[3])


def get_games():
    f = open(Constants.FILENAME, "r")
    games = []
    for line in f.readlines():
        if line := line.rstrip():
            games.append(line.split())
    f.close()
    return games    

def get_amount_of_games_per_person(games):
    for game in games:
        player_scores[game[0]][1] += 1
        player_scores[game[1]][1] += 1
        player_scores[game[4]][1] += 1
        player_scores[game[5]][1] += 1
    
def run_algo(games):
    for game in games:
        add_game_score(game)
    for player in player_scores:
        item = player_scores[player]
        average = 1000
        if(player_scores[player][1] > 0):
            average = np.mean(player_scores[player][2])
        item[0] = average
        item[2] = []

def calculate_scores():
    print("Calculating scores...")

    games = get_games()
    get_amount_of_games_per_person(games)
    n_iters = 1001

    for i in range(0, n_iters):            
        run_algo(games)
            
def show_scores(player_scores):
    print("Here are the scores: ")
    sum = 0
    num_sum = 0
    min_games = 5
    for key in player_scores:
        if player_scores[key][1] >= 1: 
            print(Constants.VALID_PLAYERS[key], ":", player_scores[key][0])
            sum += player_scores[key][0]
            num_sum += 1
        else:
            print(Constants.VALID_PLAYERS[key], ":", 0)
        
    print("Average score: ", sum / num_sum)

calculate_scores()
show_scores(player_scores)

# while s := input("For a score breakdown per person, enter their initials. To quit, enter q: ").upper():
#     if(s == 'Q'):
#         exit(0)
#     if(Constants.check_valid_initials(s)):
#         print(s)
#     else:
#         print("Invalid entry")


