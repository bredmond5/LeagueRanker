//
//  PlayerGame.swift
//  ScoreSender
//
//  Created by Brice Redmond on 8/20/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

class PlayerGame: Game {
    let gameScore: Double
    let sigmaChange: Double
    
//    init(team1: [String], team2: [String], scores: [Int], date: Int = String(Int(Date.timeIntervalSinceReferenceDate * 1000)), inputter: String, gameScore: Double, sigmaChange: Double) {
//        self.gameScore = gameScore
//        self.sigmaChange = sigmaChange
//        super.init(team1: team1, team2: team2, scores: scores, date: date, inputter: inputter)
//    }
    
    init(game: Game, gameScore: Double, sigmaChange: Double) {
        self.gameScore = gameScore
        self.sigmaChange = sigmaChange
        super.init(id: game.id, team1: game.team1, team2: game.team2, scores: game.scores, date: game.date, inputter: game.inputter)
    }
    
    override func toAnyObject() -> Any {
        return [
            "game" : super.toAnyObject(),
            "gameScore" : self.gameScore,
            "sigmaChange" : self.sigmaChange
        ]
    }
}
