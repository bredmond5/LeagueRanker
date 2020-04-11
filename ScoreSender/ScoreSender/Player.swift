//
//  Player.swift
//  ScoreSender
//
//  Created by Brice Redmond on 4/9/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation
import SwiftUI

struct Player: Identifiable {
    let id = UUID()
    let displayName: String
    let image: UIImage
    let ranking: Int
    var score: Int
    var playerGames: [PlayerGame] = []
}
