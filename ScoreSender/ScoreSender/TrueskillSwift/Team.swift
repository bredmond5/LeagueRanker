//
//  Team.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 7/8/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

public class Team<TPlayer: Hashable> {
    private var _PlayerRatings: [TPlayer: Rating] = [:]
    
    init() {
        
    }
    
    init(firstPlayer: TPlayer, playerRating: Rating) {
        let _ = AddPlayer(player: firstPlayer, rating: playerRating)
    }
    
    public func AddPlayer (player: TPlayer, rating: Rating) -> Team<TPlayer> {
        _PlayerRatings[player] = rating
        return self
    }
    
    public func AsDictionary() -> [TPlayer: Rating] {
        return _PlayerRatings
    }
    
//    public class Team: Team<Player> {
//        override init() {
//
//        }
//
//        init(player: Player, rating: Rating) {
//            super.init(player: player, rating: rating)
//        }
//    }
    
}

public class Teams {
    public static func Concat<TPlayer>(_ teams: Team<TPlayer>...) -> [[TPlayer: Rating]] {
        var ret: [[TPlayer: Rating]] = []
        for team in teams {
            ret.append(team.AsDictionary())
        }
        return ret
    }
}




