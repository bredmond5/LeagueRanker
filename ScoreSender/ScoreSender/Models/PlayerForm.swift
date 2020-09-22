//
//  Player.swift
//  ScoreSender
//
//  Created by Brice Redmond on 4/9/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation
import SwiftUI
import FirebaseDatabase
import FirebaseStorage


class PlayerForm: Identifiable, ObservableObject, Comparable, Hashable {
    
    let phoneNumber: String
    @Published var displayName: String
    @Published var image: UIImage?
    var rank: Int
    @Published var rating: Rating
    @Published var playerGames: [PlayerGame] = []
    var id: String
    var realName: String
    @Published var wins: Int = 0
    @Published var losses: Int = 0
    var rivals: [String: Double] = [:]
    var bestTeammates: [String: Double] = [:]
    let numPlacementsRequired: Int
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)        
    }
    
    static func < (lhs: PlayerForm, rhs: PlayerForm) -> Bool {
        if lhs.wins + lhs.losses < lhs.numPlacementsRequired && rhs.wins + rhs.losses < rhs.numPlacementsRequired {
            return lhs.wins + lhs.losses > rhs.wins + rhs.losses
        } else if lhs.wins + lhs.losses < lhs.numPlacementsRequired {
            return false
        } else if rhs.wins + rhs.losses < rhs.numPlacementsRequired {
            return true
        }
        return lhs.rating.Mean > rhs.rating.Mean
    }
    
    static func == (lhs: PlayerForm, rhs: PlayerForm) -> Bool {
        
        return lhs.rating.Mean == rhs.rating.Mean
    }
    
    init(uid: String, displayName: String, image: UIImage? = nil, rank: Int, rating: Rating, playerGames: [PlayerGame] = [], realName: String, numPlacementsRequired: Int, phoneNumber: String, creatorID: String? = nil) {
        id = uid
//        self.phoneNumber = phoneNumber
        self.displayName = displayName
        self.image = image
        self.rank = rank
        self.rating = rating
        self.playerGames = playerGames
        self.realName = realName
        self.numPlacementsRequired = numPlacementsRequired
        self.phoneNumber = phoneNumber
    }
    
    func toAnyObject() -> Any {
        var playerDict = [String : AnyObject]()
        playerDict["mu"] = rating.Mean as AnyObject
        playerDict["sigma"] = rating.StandardDeviation as AnyObject
        playerDict["displayName"] = displayName as AnyObject
        playerDict["realName"] = realName as AnyObject
        playerDict["phoneNumber"] = phoneNumber as AnyObject
        return playerDict
    }
    
    func getImage(leagueID: String) {
        let r = Storage.storage().reference().child("\(leagueID)\(id).jpg")
        
        r.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Player image error: \(error.localizedDescription)")

            } else {
                if let image = UIImage(data: data!) {
                    self.image = image
                }
            }
        }
    }
    
    func changeDisplayName(newDisplayName: String, leagueID: String, callback: @escaping (Error?) -> ()) {
        Database.database().reference(withPath: "leagues/\(leagueID)/players/\(id)/displayName").setValue(newDisplayName) { (error, ref) -> Void in
            if let error = error {
                callback(error)
            } else {
                callback(nil)
                self.displayName = newDisplayName
            }
        }
    }
    
    func setGamesInfo(rivals: [String: Double], bestTeammates: [String: Double]) {
        self.rivals = rivals
        self.bestTeammates = bestTeammates
    }
    
    func setValues(toOtherPlayer player: PlayerForm) {
        self.rating = player.rating
        self.playerGames = player.playerGames
        self.wins = player.wins
        self.losses = player.losses
        self.rank = player.rank
    }
    
    func enoughGames() -> Bool {
        return self.wins + self.losses >= self.numPlacementsRequired
    }
}
