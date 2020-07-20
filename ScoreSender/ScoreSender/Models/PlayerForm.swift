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


class PlayerForm: Identifiable, ObservableObject, Comparable {
    static func < (lhs: PlayerForm, rhs: PlayerForm) -> Bool {
        return lhs.rating.Mean > rhs.rating.Mean
    }
    
    static func == (lhs: PlayerForm, rhs: PlayerForm) -> Bool {
        return lhs.rating.Mean == rhs.rating.Mean
    }
    
    let phoneNumber: String
    @Published var displayName: String
    @Published var image: UIImage
    var rank: Int // id is their ranking
    var rating: Rating
    var playerGames: [Game] = []
    var id: UUID
    
    init(phoneNumber: String, displayName: String, image: UIImage = UIImage(), rank: Int, rating: Rating, playerGames: [Game] = []) {
        id = UUID()
        self.phoneNumber = phoneNumber
        self.displayName = displayName
        self.image = image
        self.rank = rank
        self.rating = rating
        self.playerGames = playerGames
    }
    
//    func toAnyObject() -> Any {
//        var retVal = [String : AnyObject]()
//
//        retVal["displayName"] = displayName as AnyObject
//        retVal["id"] = String(id) as AnyObject
//        retVal["score"] = String(score) as AnyObject
//       // retVal["playerGames"] = playerGames as AnyObject
//
//        return retVal
//    }
    
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
    
    func changeDisplayName(newDisplayName: String, leagueID: String) {
        Database.database().reference(withPath: "/\(leagueID)/players/\(phoneNumber)").setValue(newDisplayName)
        //how to handle duplicate displayNames?
        for playerGame in playerGames {
            if playerGame.team1.contains(displayName) {
                
            }else{
                
            }
        }
        
        displayName = newDisplayName
        return
    }
}
