//
//  Game.swift
//  ScoreSender
//
//  Created by Brice Redmond on 4/9/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Game: Identifiable, Hashable {
    let id: String
    var team1: [String]
    var team2: [String]
    var scores: [String]
    let date: String
    let gameScore: Double
    let sigmaChange: Double
    var inputter: String?
    
    init(team1: [String], team2: [String], scores: [String], key: String = "", gameScore: Double, sigmaChange: Double, date: String = String(Int(Date.timeIntervalSinceReferenceDate * 1000)), inputter: String? = nil) {
        self.team1 = team1
        self.team2 = team2
        self.scores = scores
        self.id = date
        self.gameScore = gameScore
        self.sigmaChange = sigmaChange
        self.date = date
        self.inputter = inputter
    }
    
    init?(gameDict: NSDictionary, date: String) {
        var scores: [String] = []
        var teams: [[String]] = []
        
        var gs = 0.0
        var sc = 0.0
        var inputter: String?
        
        for key in gameDict {
            if let keyString = key.key as? String {
                if keyString == "gameScore" {
                    gs = key.value as! Double
                }else if keyString == "sigmaChange" {
                    sc = key.value as! Double
                }else if keyString == "inputter" {
                    inputter = key.value as? String
                
                }else{
                    scores.append(key.key as! String)
                    let displayNames = key.value as! [String]
                    let p1 = displayNames[0]
                    let p2 = displayNames[1]
                    teams.append([p1,p2])
                }
            }
        }
        
        self.id = date
        self.team1 = teams[0]
        self.team2 = teams[1]
        self.scores = scores
        self.date = date
        self.gameScore = gs
        self.sigmaChange = sc
        
        if let inputter = inputter {
            self.inputter = inputter
        }else{
            self.inputter = nil
        }
    }
    
    func toAnyObject() -> Any {
        var gameDict = [String: AnyObject]()
        let team1Arr = [team1[0], team1[1]]
        let team2Arr = [team2[0], team2[1]]
        
        gameDict[scores[0]] = team1Arr as AnyObject
        gameDict[scores[1]] = team2Arr as AnyObject
        gameDict["gameScore"] = gameScore as AnyObject
        gameDict["sigmaChange"] = sigmaChange as AnyObject
        
        if let inputter = self.inputter {
            gameDict["inputter"] = inputter as AnyObject
        }
        
        return gameDict
    }

}

//struct PlayerGame {
//    let game: Game
//    
//    
//    func toAnyObject() -> Any {
//        return [
//            "game": game as AnyObject,
//5            "gameScore": gameScore,
//        ]
//    }
//}

