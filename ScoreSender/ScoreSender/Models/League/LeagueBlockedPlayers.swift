//
//  LeagueBlockedPlayers.swift
//  ScoreSender
//
//  Created by Brice Redmond on 9/16/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation
import FirebaseDatabase

class LeagueBlockedPlayers {
    
    let ref: DatabaseReference
    @Published var blockedPlayers: [String: [String]] //uid : [displayName, phonenumber, realName]
    weak var leagueSettings: LeagueSettings?
    
    init(ref: DatabaseReference, leagueSettings: LeagueSettings) {
        self.ref = ref
        self.blockedPlayers = [:]
        self.leagueSettings = leagueSettings
        
        observeBlockedUsers()
    }
    
    func observeBlockedUsers() {
        ref.observe(.value) { [weak self] snapshot in
            guard let self = self else {
                return
            }
            self.blockedPlayers = [:]
            if let blockedUIDs = snapshot.value as? NSDictionary {
                for each in blockedUIDs {
                    if let blockUID = each.value as? NSArray {
                        let playerArr = [blockUID[0] as! String, blockUID[1] as! String, blockUID[2] as! String]
                        self.blockedPlayers[each.key as! String] = playerArr
                    }
                }
            }
        }
    }
    
    deinit {
        print("blocked players deinit called")
        ref.removeAllObservers()
    }
    
    func block(_ player: PlayerForm) {
        
    }
}
