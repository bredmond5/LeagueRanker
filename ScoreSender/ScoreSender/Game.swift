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
    let players: [String]
    let scores: [String]
    let ref: DatabaseReference?
    
    init(players: [String], scores: [String], key: String = "") {
        self.ref = nil
        self.players = players
        self.scores = scores
        self.id = key
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let players = value["players"] as? [String],
            let scores = value["scores"] as? [String]
            else {
                return nil
            }
        self.ref = snapshot.ref
        self.id = snapshot.key
        self.players = players
        self.scores = scores
    }
    
    func toAnyObject() -> Any {
        return [
            "players": players,
            "scores": scores,
        ]
    }
}

struct PlayerGame {
    let game: Game
    let gameScore: Int
}

