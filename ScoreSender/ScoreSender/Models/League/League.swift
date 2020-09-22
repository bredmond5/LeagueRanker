//
//  League.swift
//  
//
//  Created by Brice Redmond on 4/11/20.
//

import SwiftUI
import FirebaseDatabase
import FirebaseStorage
import CoreData

struct League: Identifiable, Comparable {

    @EnvironmentObject var session: FirebaseSession
    var refresher: Bool = false

    let ref: DatabaseReference
    let leaguePath: String
    let id: UUID
    var leagueSettings: LeagueSettings
    var leagueBlockedPlayers: LeagueBlockedPlayers?
    var leagueGames: LeagueGames?
    var leaguePlayers: LeaguePlayers?
            
    static func < (lhs: League, rhs: League) -> Bool {
        return lhs.leagueSettings.changeDate < rhs.leagueSettings.changeDate
    }
    
    public enum LeagueErrors: LocalizedError {
        case NilObject
    }
    
    public var name: String {
        return leagueSettings.name
    }
    
    public var image: UIImage {
        return leagueSettings.dbImage.image
    }
    
    public var sortedPlayers: [PlayerForm] {
        return leaguePlayers?.sortedPlayers ?? []
    }
    
    public var playersDict: [String: PlayerForm] {
        return leaguePlayers?.players ?? [:]
    }
    
    public var owner: PlayerForm? {
        return leaguePlayers?.players[leagueSettings.creatorUID]
    }
    
    public var blockedPlayers: [String: [String]] {
        return leagueBlockedPlayers?.blockedPlayers ?? [:]
    }
    
    public var games: [Game] {
        return leagueGames?.leagueGames ?? []
    }
    
    public var numPlacements: Int {
        return leagueSettings.numPlacements
    }
    
    static func == (lhs: League, rhs: League) -> Bool { // this could use some work probably
        return lhs.id == rhs.id
    }


    init?(id: UUID) {
        self.leaguePath = "leagues/\(id)"
        self.ref = Database.database().reference(withPath: leaguePath)

        self.id = id
        self.leagueSettings = LeagueSettings(ref: ref.child("settings"), leagueImageStoragePath: "\(self.id)/\(self.id).jpg", leagueID: id.uuidString)
        self.leagueSettings.firstCompletion = {
            
            self.leagueBlockedPlayers = LeagueBlockedPlayers(ref: self.ref.child("blockedUsers"), leagueSettings: self.leagueSettings)
            self.leaguePlayers = LeaguePlayers(ref: self.ref.child("players"), leagueSettings: self.leagueSettings)
            self.leagueGames = LeagueGames(ref: self.ref.child("games"), leagueSettings: self.leagueSettings, needsSorting: {
                self.leaguePlayers?.sortPlayers()
                self.refresher = false
            })
            
            self.leagueSettings.needsSorting = { 
                self.leaguePlayers?.sortPlayers()
                self.refresher = false
            }
        }
    }
    
    func changeLeagueImage(newImage: UIImage, completion: @escaping (Bool) -> ()) {
        leagueSettings.changeLeagueImage(newImage: newImage, completion: { b in
            completion(b)
        })
    }
    
    func remove(player: PlayerForm, shouldDeletePlayerGames: Bool, shouldDeletePlayerInputGames: Bool) {
        guard let leagueGames = self.leagueGames, let leaguePlayers = self.leaguePlayers, let leagueBlockedPlayers = self.leagueBlockedPlayers else {
            print("remove blocked by nil league...")
           // completion(LeagueErrors.NilObject)
            return
        }
        
        leagueGames.removeGames(from: player, shouldDeletePlayerGames: shouldDeletePlayerGames, shouldDeletePlayerInputGames: shouldDeletePlayerInputGames)
        leaguePlayers.remove(player)
        leagueBlockedPlayers.block(player)
    }
    
    func add(game: Game, completion: @escaping (Error?) -> ()) {
        guard let leagueGames = self.leagueGames, let leaguePlayers = self.leaguePlayers, let playersUpdate = leaguePlayers.getDictionary(forGame: game) else {
            print("failed in add game in league")
            completion(LeagueErrors.NilObject)
            return
        }
        
        let gameUpdate = leagueGames.getDictionary(forGame: game)
        let settingsUpdate = leagueSettings.getUpdateChangeDateDictionary()
        
        let merge = gameUpdate.merging(playersUpdate) { (current, _) in current }
        
        self.ref.updateChildValues(merge.merging(settingsUpdate){ (current, _) in current }, withCompletionBlock: { error, ref in
            self.leaguePlayers?.sortPlayers()
            completion(error)
        })
    }
    
//    func returnPlayers() -> [PlayerForm] {
//        return leaguePlayers.sortedPlayers
//    }
    
    func datasourceForAutocomplete() -> [String : String] {
        guard let players = leaguePlayers?.sortedPlayers else {
            print("failed getting leaguePlayers")
            return [:]
        }
        var displayNames: [String: String] = [:]
        var realNames: [String : String] = [:]
        var duplicates: [String] = []
        for player in players {
            displayNames[player.displayName] = player.displayName
            if realNames[player.realName] != nil { // If multiple people have the same real name dont want it autofinishing
                realNames[player.realName] = nil
                duplicates.append(player.realName)
            } else if !duplicates.contains(player.realName) {
                realNames[player.realName] = player.displayName
//                datasource[player.phoneNumber] = player.displayName
            }
        }
        return displayNames.merging(realNames) { (current, _) in current }
    }
    
    func player(atID uid: String) -> PlayerForm? {
        return leaguePlayers?.players[uid]
    }
    
    func player(atDisplayName displayName: String) -> PlayerForm? {
        guard let uid = leaguePlayers?.displayNameToUserID[displayName] else {
            return nil
        }
        return leaguePlayers?.players[uid]
    }
    
    func player(atPhoneNumber phoneNumber: String) -> PlayerForm? {
        guard let uid = leaguePlayers?.phoneNumberToUID[phoneNumber] else {
            return nil
        }
        return leaguePlayers?.players[uid]
    }
    
    func ownsLeague(userID: String) -> Bool {
        return userID == leagueSettings.creatorUID
    }
    
    
//    func getLocalImageGroup(context: NSManagedObjectContext) -> LocalImageGroup? {
//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalImageGroup")
//        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
//
//        do {
//            let fetch = try context.fetch(request)
//            let localImageGroup = fetch as! [LocalImageGroup]
//            return localImageGroup.first
//        } catch {
//            print("localImageGroup fetch failed")
//            return nil
//        }
//    }
    
    func removeAllObservers() {
        
    }
    
//    func toAnyObject() -> Any {
//        // toAnyObject just used initially to upload league, games and blocked users will be empty here
//        return [
//            "settings" : leagueSettings.toAnyObject(),
////            "games" : leagueGames.toAnyObject(),
//            "players" : leaguePlayers.toAnyObject(),
////            "blockedUsers" : leagueBlockedPlayers.toAnyObject()
//        ]
//    }
    
    func changeRealName(forUID uid: String, newName: String, completion: ((Error?) -> Void)? = nil) {
        guard let leaguePlayers = self.leaguePlayers else {
            completion?(LeagueErrors.NilObject)
            return
        }
        leaguePlayers.changeRealName(forUID: uid, newName: newName, completion: { error in
            completion?(error)
        })
    }
    
//    func deleteGame(forDate date: String, forPlayer player: PlayerForm, callback: @escaping ([Game]) -> ()) {
//        League.getLeagueFromFirebase(forLeagueID: self.id.uuidString, forDisplay: false, shouldGetGames: true, callback: { league in
//            if let league = league {
//                var allGamesAfterDate: [Int: Game] = [:]
//                for player in league.players.values {
//                    //get their initial ratings
//                    var mean = player.rating.Mean
//                    var sigma = player.rating.StandardDeviation
//                    while let game = player.playerGames.first, Int(game.date)! > Int(date)! {
//                        //bubble back each time to get back to the original game
//                        mean -= game.gameScore
//                        sigma -= game.sigmaChange
//                        allGamesAfterDate[Int(game.date)!] = game
//                        player.playerGames.removeFirst()
//                        if game.gameScore > 0 {
//                           player.wins -= 1
//                       } else{
//                           player.losses -= 1
//                       }
//                    }
//
//                    if let game = player.playerGames.first, game.date == date && (game.team1.contains(player.id) || game.team2.contains(player.id)) {
//                        mean -= game.gameScore
//                        sigma -= game.sigmaChange
//                        player.playerGames.removeFirst() // remove the actual game but dont add it to allgamesafterdate
//                        if game.gameScore > 0 {
//                            player.wins -= 1
//                        } else{
//                            player.losses -= 1
//                        }
//                    }
//
//                    self.players[player.id]?.rating = Rating(mean: mean, standardDeviation: sigma)
//                    self.players[player.id]?.playerGames = player.playerGames
//                    self.players[player.id]?.wins = player.wins
//                    self.players[player.id]?.losses = player.losses
//
//                    //set the player rating to whatever it was before this game
////                    player.rating = Rating(mean: mean, standardDeviation: sigma)
//                }
//                //callback(self.calculateRankingsFromDictionary(allGamesAfterDate))
//            }
//        })
//    }
    
//    func calculateRankingsFromDictionary(_ allGamesAfterDate: [Int: Game]) -> [[Game]] {
//        var gamesToUpload: [[Game]] = []
//        //iterate through all the games, calculating the new rankings
//        for (_, value) in allGamesAfterDate.sorted(by: { $0.0 < $1.0 }) {
//            addGame(value, completion: { games in
//                gamesToUpload.append(games)
//            })
//        }
//
//        for player in players.values {
//            player.playerGames.sort(by: {$0.date > $1.date})
//        }
//
//        self.rankPlayers()
//        return gamesToUpload
//    }
//
////    func recalculateRankings(callback: @escaping ([Game]) -> ()) {
////        // pull the league so that can get any new games just in case
////        League.getLeagueFromFirebase(forLeagueID: self.id.uuidString, forDisplay: false, shouldGetGames: true, callback: { league in
////            if let league = league {
////                //reset the rankings
////                let gameInfo = GameInfo.DefaultGameInfo
////                for player in self.players.values {
////                    player.rating = gameInfo.DefaultRating
////                    player.playerGames = []
////                    player.wins = 0
////                    player.losses = 0
////                }
////
////                let games = league.leagueGames
////
////                var allGamesAfterDate: [Int: Game] = [:]
////                for player in league.players.values {
////                    // get all the games from the online league
////                   for game in player.playerGames {
////                       allGamesAfterDate[Int(game.date)!] = game
////                   }
////               }
////            }
////        })
////
    
    static func writeLeague(leagueName: String, image: UIImage, creator: User, creatorDisplayName: String, creatorImage: UIImage, numPlacements: Int, playersPerTeam: Int, completion: @escaping (String) -> ()) {
        
        let id = UUID()
        let leaguePath = "leagues/\(id)"
        let ref = Database.database().reference(withPath: leaguePath)
        
        var writeObject = [String: Any]()
        
        let group = DispatchGroup()
        
        group.enter()
        
        //TODO: create the core data local images here so extra download doesnt need to happen
        settingsDict(id.uuidString, image, numPlacements, playersPerTeam, leagueName, creator.uid, completion: { any in
            writeObject["settings"] = any
            group.leave()
        })
        
        group.enter()
        playersDict(id.uuidString, creator: creator, creatorDisplayName: creatorDisplayName, creatorImage: creatorImage, completion: { any in
            writeObject["players"] = any
            group.leave()
        })
        
        
        group.notify(queue: .main) {
            ref.setValue(writeObject) { error, ref in
                completion(id.uuidString)
            }
        }
    }
    
    private static func settingsDict(_ id: String, _ leagueImage: UIImage, _ numPlacements: Int, _ playersPerTeam: Int, _ name: String, _ creatorUID: String, completion: @escaping (Any) -> ()) {
        
        
        StorageService.uploadImage(leagueImage, at: Storage.storage().reference(withPath: "\(id)/\(id).jpg"), completion: { url in
            let date = Int64(Date().timeIntervalSince1970 * 1000)

            completion(["settings" : [
                "nPlacements" : numPlacements,
                "ppTeam" : playersPerTeam,
                "name" : name,
                "creatorUID" : creatorUID,
                "changeDate" : date,
                "nPlayers" : 1
                ],
            "icDate" : date
            ] as Any)
        })
    }

    private static func playersDict(_ leagueID: String, creator: User, creatorDisplayName: String, creatorImage: UIImage, completion: @escaping(Any) -> ()) {
        newPlayerDict(leagueID, playerID: creator.uid, creator.realName!, creator.phoneNumber!, creatorDisplayName, creatorImage, completion: { playerDict in
            var playersDict = [String : AnyObject]()
            var playerIDs = [String : AnyObject]()
            var displayNames = [String : AnyObject]()
            playersDict[creator.uid] = playerDict as AnyObject
            playerIDs[creator.uid] = true as AnyObject
            displayNames[creatorDisplayName] = true as AnyObject
            
            completion(["objects" : playersDict, "playerIDs" : playerIDs, "displayNames" : displayNames] as AnyObject)
        })
    }
    
    public static func newPlayerDict(_ leagueID: String, playerID: String, _ realName: String, _ phoneNumber: String, _ displayName: String, _ image: UIImage, completion: @escaping(Any) -> ()) {
        StorageService.uploadImage(image, at: Storage.storage().reference(withPath: "\(leagueID)/\(playerID).jpg"), completion: { url in
            var playerDict = [String : AnyObject]()
            var values = [String : AnyObject]()
            let rating = GameInfo.DefaultGameInfo.DefaultRating
            values["mu"] = rating.Mean as AnyObject
            values["sigma"] = rating.StandardDeviation as AnyObject
            values["displayName"] = displayName as AnyObject
            values["realName"] = realName as AnyObject
            values["phoneNumber"] = phoneNumber as AnyObject
            values["wins"] = 0 as AnyObject
            values["losses"] = 0 as AnyObject
            playerDict["values"] = values as AnyObject
            playerDict["icDate"] = Int64(Date().timeIntervalSince1970 * 1000) as AnyObject
            completion(playerDict)
        })
    }
}

extension League.LeagueErrors {
    public var errorDescription: String? {
        switch self {
            
        case .NilObject:
            return NSLocalizedString("Internal league error", comment: "My error")
        }
    }
}

