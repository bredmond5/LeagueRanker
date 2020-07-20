//
//  League.swift
//  
//
//  Created by Francisco Lopez on 4/11/20.
//

import SwiftUI
import FirebaseDatabase
import FirebaseStorage

class League: Identifiable, ObservableObject {
    
    let ref: DatabaseReference?
    let id: UUID
    var players: [String : PlayerForm] = [:]
    var displayNameToPhoneNumber: [String : String] = [:]
    var name: String
    var leagueImage: UIImage?
    var creatorPhone: String // phone number of creator
    
    //Default init for before the real leagues have been downloaded
    init() {
        self.ref = nil
        self.id = UUID()
        self.leagueImage = UIImage()
        self.name = "No Leagues"
        self.creatorPhone = ""
    }
        
    init(name: String, id: UUID = UUID(), image: UIImage, creatorPhone: String, creatorDisplayName: String, creatorImage: UIImage) {
        self.ref = nil
        self.id = id
        self.name = name
        self.leagueImage = image
        self.creatorPhone = creatorPhone
        
        self.players[creatorPhone] = (PlayerForm(phoneNumber: creatorPhone, displayName: creatorDisplayName, image: creatorImage, rank: 1, rating: GameInfo.DefaultGameInfo.DefaultRating))
        self.displayNameToPhoneNumber[creatorDisplayName] = creatorPhone
//        self.players[creator.phoneNumber!]!.playerGames.append(Game(team1: ["+16506693169", "+16505553434"], team2: ["+16505551234", "+16505554321"], scores: ["12", "5"], gameScore: -1.5))
        //runAlgorithm()
    }
    
    init?(snapshot: DataSnapshot, id: String, callingFunction: String) {
        print("league initializer called by " + callingFunction)
       guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["leagueName"] as? String,
            let creatorPhone = value["creatorPhone"] as? String,
            let id = UUID(uuidString: id)
           else {
                print("Failed in league snapshot initializer")
                return nil
           }
        
        self.ref = snapshot.ref
        self.name = name
        self.creatorPhone = creatorPhone
        self.id = id
        getPlayersSorted(value["players"] as? NSDictionary)
        getImage()
    }
    
    func returnPlayers() -> [PlayerForm] {
        var ret: [PlayerForm] = []
        for each in players {
            ret.append(each.value)
        }
        return ret
    }
    
    func getPlayersSorted(_ playersDict: NSDictionary?) {
        
        guard let playersDict = playersDict else {
            print("failed in playersDict")
            return
        }

        //maybe should rework these next 5 lines because i am storing displayNames now
        for each in playersDict {
            getPlayer(each.key as? String, each.value as? NSDictionary)
        }
        
        sortPlayers()
    }
    
    func sortPlayers() {
        var playerArr = returnPlayers()
        playerArr.sort()
        
        var count = 0
        players[playerArr[0].phoneNumber]!.rank = 1
        
        for i in 1..<playerArr.count {
            if round(playerArr[i].rating.Mean * 100) / 100 < round(playerArr[i-1].rating.Mean * 100) / 100 { // make sure this is rounding to hundredth
                count = i
            }
            players[playerArr[i].phoneNumber]!.rank = count + 1
        }
    }
    
    func getPlayer(_ phoneNumber: String?, _ playerDict: NSDictionary?) {
        guard let playerDict = playerDict, let phoneNumber = phoneNumber, let mu = playerDict["mu"] as? Double, let sigma = playerDict["sigma"] as? Double else {
            print("failed in playerDict")
            return
        }

        let p = PlayerForm(phoneNumber: phoneNumber, displayName: playerDict["displayName"] as! String, rank: 1, rating: Rating(mean: mu, standardDeviation: sigma), playerGames: [])
        
        getGames(playerDict["games"] as? NSDictionary, player: p)
        
        p.getImage(leagueID: id.uuidString)
        self.players[phoneNumber] = p
        self.displayNameToPhoneNumber[playerDict["displayName"] as! String] = phoneNumber
       
    }

    func getGames(_ gamesDict: NSDictionary?, player: PlayerForm?) {
        guard let gamesDict = gamesDict, let player = player else {
           print("failed in getGames")
           return
       }
        
        for each in gamesDict as NSDictionary {
            if let val = each.value as? NSDictionary {
                var scores: [String] = []
                var teams: [[String]] = []
                var gameScore = 0.0
                for key in val {
                    if let gs = key.value as? Double {
                        gameScore = gs
                    }else{
                        scores.append(key.key as! String)
                        let displayNames = key.value as! [String]
                        let p1 = displayNames[0]
                        let p2 = displayNames[1]
                        teams.append([p1,p2])
                    }
                }
                player.playerGames.append(Game(team1: teams[0], team2: teams[1], scores: scores, gameScore: gameScore, date: each.key as! String))
            }
        }
    }
    
    func getImage() {
        let r = Storage.storage().reference().child("\(id).jpg")

        r.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
                print("error getting league image")
            } else {
               // Data for "images/island.jpg" is returned
                print("found league image")
                self.leagueImage = UIImage(data: data!) ?? UIImage()
            }
        }
    }
    
    func toAnyObject() -> Any {
        var retVal = [String : AnyObject]()
        retVal["leagueName"] = self.name as AnyObject
        
        var playersDict = [String : AnyObject]()
        
        for player in players {
            var playerDict = [String : AnyObject]()
            playerDict["mu"] = player.value.rating.Mean as AnyObject
            playerDict["sigma"] = player.value.rating.StandardDeviation as AnyObject
            playerDict["displayName"] = player.value.displayName as AnyObject
            
            var gamesDict = [String : AnyObject]()
            for game in player.value.playerGames {
                gamesDict[game.date] = game.toAnyObject() as AnyObject
            }
            playerDict["games"] = gamesDict as AnyObject
            
            playersDict[player.key] = playerDict as AnyObject
        }
        
        retVal["players"] = playersDict as AnyObject
        
        retVal["creatorPhone"] = creatorPhone as AnyObject
        
        return retVal
    }
    
    func changePlayerDisplayName(phoneNumber: String, newDisplayName: String) {
        players[phoneNumber]?.changeDisplayName(newDisplayName: newDisplayName, leagueID: id.uuidString)
    }
    
    func changePlayerImage(phoneNumber: String, newImage: UIImage) {
        players[phoneNumber]?.image = newImage
    }
}
