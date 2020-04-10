//
//  Game.swift
//  ScoreSender
//
//  Created by Brice Redmond on 4/9/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

struct Game: Identifiable {
    let id = UUID()
    let players: [String]
    let scores: [String]
}

//struct Games: Identifiable {
    
//}
