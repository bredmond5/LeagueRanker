//
//  League.swift
//  
//
//  Created by Francisco Lopez on 4/11/20.
//

import Foundation
import SwiftUI

class League {
    
    var users: [User] //commisioner will be user 0
    var games: [Game]?
    var players: [Player] = []
    
    init(users: [User], games: [Game]?) {
        self.users = users
        self.games = games
        createPlayers()
        runAlgorithm()
    }
        
    func createPlayers() {
        for user in users {
            players.append(Player(displayName: user.displayName, image: (user.image ?? UIImage(named: "jobs")!)!, ranking: 0, score: 1000))
        }
    }
    
    func runAlgorithm() {
        if let games = self.games {
            let n_iters = 1000
            for _ in 0 ..< n_iters {
                for game in games {
                    changePlayerScores(game)
                }
                for i in 0 ..< players.count {
                    var average = 0
                    if(players[i].playerGames.count > 4) {
                        var sum = 0
                        for j in 0 ..< players[i].playerGames.count {
                            sum += players[i].playerGames[j].gameScore
                        }
                        average = sum / players[i].playerGames.count
                    }
                    players[i].score = average
                    players[i].playerGames = []
                }
            }
        }
    }
    
    func changePlayerScores(_ game: Game) {
//        rating_differential, team_1_won = get_rating_differential(game)
//
//        team_1_average_score = (player_scores[game[0]][0] + player_scores[game[1]][0]) / 2
//        team_2_average_score = (player_scores[game[4]][0] + player_scores[game[5]][0]) / 2
//
//        t1_add = team_2_average_score
//        t2_add = team_1_average_score
//
//        if team_1_won:
//            t2_add -= rating_differential
//            t1_add += rating_differential
//        else:
//            t2_add += rating_differential
//            t1_add -= rating_differential
//
//        add = t1_add
//        for i in range(0,6):
//            if(i != 2 and i != 3):
//                item = player_scores[game[i]]
//                item[1].append(add)
//            else:
//                add = t2_add
    }
    
    func getRatingDifferential(_ game: Game) {
//        winning_score, losing_score = get_game_score(game[2], game[3])
//        r = losing_score/(winning_score - 1)
//        numerator = 475 * math.sin(min(1, (1 - r) / .5) * .4*math.pi)
//        denominator = math.sin(.4*math.pi)
//        return 125 + numerator/denominator, winning_score == int(game[2])
    }
    
    func getGameScore(s1: String, s2: String) {
//        s1 = int(s1)
//        s2 = int(s2)
//        if(s1 < s2):
//            tmp = s1
//            s1 = s2
//            s2 = tmp
//        return s1, s2
    }
}
