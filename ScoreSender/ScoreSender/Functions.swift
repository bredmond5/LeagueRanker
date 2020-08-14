//
//  Functions.swift
//  ScoreSender
//
//  Created by Brice Redmond on 4/9/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation
import SwiftUI

class Functions {
    static func checkValidGameAndGetGameScores(players: [String], scores: [String], ratings: [Rating], gameDate: String = String(Int(Date.timeIntervalSinceReferenceDate * 1000)), inputter: String) -> (Game, [Rating])? {
        
        if(players.count != Set(players).count)  {
            return nil
        }
        
        let newRatings = getNewRatings(players: players, scores: scores, ratings: ratings)
        
        return (Game(team1: [players[0], players[1]], team2: [players[2], players[3]], scores: [scores[0], scores[1]], gameScore: 0, sigmaChange: 0, date: gameDate, inputter: inputter), [newRatings[0], newRatings[1], newRatings[2], newRatings[3]])
    }
    
    static func getNewRatings(players: [String], scores: [String], ratings: [Rating]) -> [Rating] {
       let gameInfo = GameInfo.DefaultGameInfo

       let player1 = Player(id: players[0])
       let player2 = Player(id: players[1])
       let player3 = Player(id: players[2])
       let player4 = Player(id: players[3])

       let team1 = Team().AddPlayer(player: player1, rating: ratings[0]).AddPlayer(player: player2, rating: ratings[1])
       let team2 = Team().AddPlayer(player: player3, rating: ratings[2]).AddPlayer(player: player4, rating: ratings[3])

       let teams = Teams.Concat(team1, team2)
       var newRatings: [Player<String>: Rating]
       
       if Int(scores[0])! > Int(scores[1])! {
           newRatings = TrueSkillCalculator.CalculateNewRatings(gameInfo: gameInfo, teams: teams, teamRanks: 1,2)
       }else{
           newRatings = TrueSkillCalculator.CalculateNewRatings(gameInfo: gameInfo, teams: teams, teamRanks: 2,1)
       }
        return [newRatings[player1]!, newRatings[player2]!, newRatings[player3]!, newRatings[player4]!]
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}  
