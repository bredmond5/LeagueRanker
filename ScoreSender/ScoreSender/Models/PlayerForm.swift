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
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    //        hasher.combine(displayName) //displayname will also be unique
        
    }
    
    static func < (lhs: PlayerForm, rhs: PlayerForm) -> Bool {
        return lhs.rating.Mean > rhs.rating.Mean
    }
    
    static func == (lhs: PlayerForm, rhs: PlayerForm) -> Bool {
        return lhs.rating.Mean == rhs.rating.Mean
    }
    
    let phoneNumber: String
    @Published var displayName: String
    @Published var image: UIImage
    var rank: Int
    @Published var rating: Rating
    @Published var playerGames: [Game] = []
    var id: UUID
    var realName: String
    @Published var wins: Int = 0
    @Published var losses: Int = 0
    var rivals: [String: Double] = [:]
    var bestTeammates: [String: Double] = [:]
    
    init(phoneNumber: String, displayName: String, image: UIImage = UIImage(), rank: Int, rating: Rating, playerGames: [Game] = [], realName: String) {
        id = UUID()
        self.phoneNumber = phoneNumber
        self.displayName = displayName
        self.image = image
        self.rank = rank
        self.rating = rating
        self.playerGames = playerGames
        self.realName = realName
    }
    
    func toAnyObject() -> Any {
        var playerDict = [String : AnyObject]()
        playerDict["mu"] = rating.Mean as AnyObject
        playerDict["sigma"] = rating.StandardDeviation as AnyObject
        playerDict["displayName"] = displayName as AnyObject
        playerDict["realName"] = realName as AnyObject
        
        var gamesDict = [String : AnyObject]()
        for game in playerGames {
            gamesDict[game.date] = game.toAnyObject() as AnyObject
        }
        playerDict["games"] = gamesDict as AnyObject
        
        return playerDict
    }
    
    func getImage(leagueID: String) {
        let r = Storage.storage().reference().child("\(leagueID)\(phoneNumber).jpg")

        r.getData(maxSize: 1 * 1024 * 1024) { data, error in
          if let error = error {
            print(error.localizedDescription)

          } else {
            //print("found \(leagueID)\(self.phoneNumber).jpg")
            self.image = UIImage(data: data!) ?? UIImage()
               
            }
        }
    }
    
    func changeDisplayName(newDisplayName: String, leagueID: String, callback: @escaping (String?) -> ()) {
        Database.database().reference(withPath: "/\(leagueID)/players/\(phoneNumber)/displayName").setValue(newDisplayName) { (error, ref) -> Void in
            if let error = error {
                callback(error.localizedDescription)
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
    
}
