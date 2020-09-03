//
//  Game.swift
//  ScoreSender
//
//  Created by Brice Redmond on 4/9/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Game: Identifiable, Hashable, Comparable {
    static func < (lhs: Game, rhs: Game) -> Bool {
        return Double(lhs.date)! < Double(rhs.date)!
    }
    
    static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    public func hash(into hasher: inout Hasher) { //definite possible issue here, should test, maybe ids should be unique?
        hasher.combine(id)
    }
    
    let id: UUID
    var team1: [String]
    var team2: [String]
    var scores: [String]
    var date: String
    var inputter: String
    
    init(id: UUID = UUID(), team1: [String], team2: [String], scores: [String], date: String = String(Int(Date.timeIntervalSinceReferenceDate * 1000)), inputter: String) {
        self.team1 = team1
        self.team2 = team2
        self.scores = scores
        self.id = id
        self.date = date
        self.inputter = inputter
    }
    
    init?(gameDict: NSDictionary, id: UUID) {
        var scores: [String] = []
        var teams: [[String]] = []
        
//        var gs = 0.0
//        var sc = 0.0
        var inputter: String = ""
        var date: String = ""
        
        for key in gameDict {
            if let keyString = key.key as? String {
                if keyString == "inputter" {
                    inputter = key.value as! String
                    
                }else if keyString == "date" {
                    date = key.value as! String
                    
                }else{
                    scores.append(key.key as! String)
                    let displayNames = key.value as! [String]
                    let p1 = displayNames[0]
                    let p2 = displayNames[1]
                    teams.append([p1,p2])
                }
            }
        }
        
        self.id = id
        self.team1 = teams[0]
        self.team2 = teams[1]
        self.scores = scores
        self.date = date

        
        self.inputter = inputter
    }
    
    func toAnyObject() -> Any {
        var gameDict = [String: AnyObject]()
        let team1Arr = [team1[0], team1[1]]
        let team2Arr = [team2[0], team2[1]]
        
        gameDict[scores[0]] = team1Arr as AnyObject
        gameDict[scores[1]] = team2Arr as AnyObject
        
        gameDict["inputter"] = inputter as AnyObject
        gameDict["date"] = date as AnyObject
        return gameDict
    }

}


