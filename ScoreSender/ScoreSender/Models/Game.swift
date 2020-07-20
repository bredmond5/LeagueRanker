//
//  Game.swift
//  ScoreSender
//
//  Created by Brice Redmond on 4/9/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Game: Identifiable {
    let id: String
    var team1: [String]
    var team2: [String]
    var scores: [String]
    let ref: DatabaseReference?
    let date: String
    let gameScore: Double
    
    init(team1: [String], team2: [String], scores: [String], key: String = "", gameScore: Double, date: String = String(Int(Date.timeIntervalSinceReferenceDate * 1000))) {
        self.ref = nil
        self.team1 = team1
        self.team2 = team2
        self.scores = scores
        self.id = date
        self.gameScore = gameScore
        self.date = date
    }
    
    init?(snapshot: DataSnapshot, date: String) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let gameScore = value["gameScore"] as? String
            else {
                print("Failed in game snapshot initializer")
                return nil
        }
        
        let enumerator = snapshot.children
        var scores: [String] = []
        var team1: [String] = []
        var team2: [String] = []
        if let rest = enumerator.nextObject() as? DataSnapshot {
            scores.append(rest.key)
            let arr = rest.value as! NSArray
            team1.append(arr[0] as! String)
            team1.append(arr[1] as! String)
        }
        if let rest = enumerator.nextObject() as? DataSnapshot {
            scores.append(rest.key)
            let arr = rest.value as! NSArray
            team2.append(arr[0] as! String)
            team2.append(arr[1] as! String)
        }
        
        self.ref = snapshot.ref
        self.id = snapshot.key
        self.team1 = team1
        self.team2 = team2
        self.scores = scores
        self.date = date
        self.gameScore = Double(gameScore)!
    }
    
    func toAnyObject() -> Any {
        var gameDict = [String: AnyObject]()
        let team1Arr = [team1[0], team1[1]]
        let team2Arr = [team2[0], team2[1]]
        
        gameDict[scores[0]] = team1Arr as AnyObject
        gameDict[scores[1]] = team2Arr as AnyObject
        gameDict["gameScore"] = gameScore as AnyObject
        
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

