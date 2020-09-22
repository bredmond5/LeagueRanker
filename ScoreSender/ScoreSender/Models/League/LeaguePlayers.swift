//
//  LeaguePlayers.swift
//  ScoreSender
//
//  Created by Brice Redmond on 9/16/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import FirebaseDatabase

class LeaguePlayers {
    
    @Published var sortedPlayers: [PlayerForm] = []
    @Published var refresher: Bool = false
    
    let ref: DatabaseReference
    
    var phoneNumberToUID: [String: String] = [:]
    var displayNameToUserID: [String : String] = [:]
    
    var players: [String : PlayerForm] = [:]
    
    weak var leagueSettings: LeagueSettings?
    
    func sortPlayers() {
        
        guard !players.isEmpty, let leagueSettings = leagueSettings else {
            return
        }
                
        print("sorting players!")
        
        self.sortedPlayers = Array(players.values).sorted(by: {
            if $0.wins + $0.losses < leagueSettings.numPlacements && $1.wins + $1.losses < leagueSettings.numPlacements {
                return $0.wins + $0.losses > $1.wins + $1.losses
            } else if $0.wins + $0.losses < leagueSettings.numPlacements {
                return false
            } else if $1.wins + $1.losses < leagueSettings.numPlacements {
                return true
            }
            return $0.rating.Mean > $1.rating.Mean
        })
        
        var count = 0
        players[sortedPlayers[0].id]!.rank = 1
        
        for i in 1..<sortedPlayers.count {
            let p1 = sortedPlayers[i]
            let p2 = sortedPlayers[i-1]
            
            if !p1.enoughGames(numPlacements: leagueSettings.numPlacements) {
                if p1.wins + p1.losses < p2.wins + p2.losses {
                    count = i
                }
            } else if round(p1.rating.Mean * 100) / 100 < round(p2.rating.Mean * 100) / 100 {
                count = i
            }
            
            players[sortedPlayers[i].id]!.rank = count + 1
        }
        self.refresher = false
    }
    
    // init from firebase
    init(ref: DatabaseReference, leagueSettings: LeagueSettings) {
        self.ref = ref
        self.leagueSettings = leagueSettings
        
        observePlayers()
    }
    
    
    func observePlayers() {
        ref.child("playerIDs").observe(.childAdded) { [weak self] snapshot in
            guard let self = self, let leagueSettings = self.leagueSettings else {
                print("failed reading player id")
                return
            }
            let player: PlayerForm = PlayerForm(ref: self.ref.child("objects/\(snapshot.key)"), leagueID: leagueSettings.leagueID)
            
            self.players[snapshot.key] = player
            player.changed = { [weak self] id, phoneNumber, displayName in
                if let p = self?.players[id] {
                     self?.displayNameToUserID[p.id] = nil
                     self?.phoneNumberToUID[p.id] = nil
                }
                self?.displayNameToUserID[displayName] = id
                
                if phoneNumber != id {
                    self?.phoneNumberToUID[phoneNumber] = id
                }
                self?.sortPlayers()
            }
        }
        
        ref.child("playerIDs").observe(.childRemoved) { [weak self] snapshot in
            guard let self = self else {
                return
            }
            if let player = self.players[snapshot.key] {
                self.players[snapshot.key] = nil
                self.displayNameToUserID[player.displayName] = nil
                self.phoneNumberToUID[player.phoneNumber] = nil
                self.sortPlayers()
            }            
        }
    }
    
    deinit {
        print("league players deinit called")
        ref.child("playerIDs").removeAllObservers()
        ref.removeAllObservers()
    }
    
    func toAnyObject() -> Any {
        var playersDict = [String : AnyObject]()
        var playerIDs = [String : AnyObject]()
        for player in players {
            playersDict[player.key] = player.value.toAnyObject() as AnyObject
            playerIDs[player.key] = true as AnyObject
        }
        
        return ["objects" : playersDict, "playerIDs" : playerIDs] as AnyObject // needs displaynames
    }
    
    func remove(_ player: PlayerForm) {
        
    }
    
    func getDictionary(forGame game: Game) -> [AnyHashable : Any]? {
        
        let playerUIDs = game.team1 + game.team2
        var ratingsBefore: [Rating] = []
        
        for uid in playerUIDs {
            guard let player = self.players[uid] else {
                return nil
            }
            ratingsBefore.append(player.rating)
        }

        let newRatings = Functions.getNewRatings(players: playerUIDs, scores: game.scores, ratings: ratingsBefore)
        var ret: [AnyHashable: Any] = [:]

        for i in 0..<playerUIDs.count {
            let uid = playerUIDs[i]
            let player = players[uid]!
            let oldPlayerMean = player.rating.Mean
            let oldPlayerSigma = player.rating.StandardDeviation
            let game = PlayerGame(game: game, gameScore: newRatings[i].Mean - oldPlayerMean, sigmaChange: newRatings[i].StandardDeviation - oldPlayerSigma)
            let playerPath = "/players/objects/\(uid)"
            ret["\(playerPath)/values/mu"] = newRatings[i].Mean
            ret["\(playerPath)/values/sigma"] = newRatings[i].StandardDeviation
            ret["\(playerPath)/games/\(game.id)"] = game.toAnyObject()
            
            if (game.team1.contains(uid) && game.scores[0] > game.scores[1]) || (game.team2.contains(uid) && game.scores[0] < game.scores[1]) {
                ret["\(playerPath)/values/wins"] =  player.wins + 1
            } else {
                ret["\(playerPath)/values/losses"] = player.losses + 1
            }
        }
        return ret
    }
    
//    func getPlayersAndRank(_ playersDict: NSDictionary, shouldGetGames: Bool) -> [String : PlayerForm] {
//        var playersOnline: [String : PlayerForm] = [:]
//        for each in playersDict {
//            let pair = getPlayer(each.key as? String, each.value as? NSDictionary, shouldGetGames: shouldGetGames)
//            if let pair = pair {
//                playersOnline[pair.0] = pair.1
//            }
//        }
//
//        LeaguePlayers.rankPlayers(players: &playersOnline)
//        return playersOnline
//    }
//
//    private static func rankPlayers(players: inout [String : PlayerForm]) {
//        var playerArr = Array(players.values)
//        playerArr.sort()
//
//        var count = 0
//        players[playerArr[0].id]!.rank = 1
//
//        for i in 1..<playerArr.count {
//            if round(playerArr[i].rating.Mean * 100) / 100 < round(playerArr[i-1].rating.Mean * 100) / 100 || (!playerArr[i].enoughGames() && playerArr[i-1].enoughGames()){
//                count = i
//            }
//            players[playerArr[i].id]!.rank = count + 1
//        }
//    }
//
//    func getPlayer(_ uid: String?, _ playerDict: NSDictionary?, shouldGetGames: Bool) -> (String , PlayerForm)? {
//        guard let playerDict = playerDict,
//            let uid = uid,
//            let mu = playerDict["mu"] as? Double,
//            let sigma = playerDict["sigma"] as? Double,
//            let displayName =  playerDict["displayName"] as? String,
//            let realName = playerDict["realName"] as? String,
//            let phoneNumber = playerDict["phoneNumber"] as? String
//
//            else {
//            print("failed in playerDict")
//            return nil
//        }
//
//        //let p = PlayerForm(phoneNumber: phoneNumber, displayName: playerDict["displayName"] as! String, rank: 1, rating: Rating(mean: mu, standardDeviation: sigma), playerGames: [], realName: playerDict["realName"] as! String)
//
//        let p = PlayerForm(uid: uid, displayName: displayName, rank: 1, rating: Rating(mean: mu, standardDeviation: sigma), playerGames: [], realName: realName, numPlacementsRequired: 15, phoneNumber: phoneNumber) // NEED TO FIX THIS
//        self.players[uid] = p
//
////            let pair = getGames(playerDict["games"] as? NSDictionary, player: p)
////            if let pair = pair {
////                p.setGamesInfo(rivals: pair.0, bestTeammates: pair.1)
////            }
//
//
//        self.phoneNumberToUID[phoneNumber] = uid
//        self.displayNameToUserID[displayName] = uid
//
//    }
//

//    func changePlayerDisplayName(uid: String, newDisplayName: String, callback: @escaping (Error?) -> ()) {
//
//        self.players[uid]?.changeDisplayName(newDisplayName: newDisplayName, leagueID: self.id.uuidString, callback: { error in
//            if let error = error {
//                callback(error)
//                return
//            }
//            self.displayNameToUserID[newDisplayName] = uid
//            callback(nil)
//        })
//    }
//
//
    func changeRealName(forUID uid: String, newName: String, completion: ((Error?) -> Void)? = nil) {
//        Database.database().reference(withPath: "leagues/\(self.id)/players/\(uid)/realName").setValue(newName) { (error, ref) -> Void in
//            if let error = error {
//                print(error.localizedDescription)
//                completion?(error)
//            } else {
//                self.players[uid]?.realName = newName
//                completion?(nil)
//            }
//        }
    }
//
//    func changePlayerImage(player: PlayerForm, newImage: UIImage, callback: @escaping (Bool) -> ()) {
//        let imageRef = Storage.storage().reference().child("\(self.id)/\(player.id).jpg")
//        StorageService.uploadImage(newImage, at: imageRef) { (downloadURL) in
//            guard let _ = downloadURL else {
//                callback(false)
//                return
//            }
//            callback(true)
//        }
//    }
//
//    func addPlayerGame(forPlayerUID uid: String, playerGame: PlayerGame, newRating: Rating?) {
//        let player = players[uid]
//
//        if playerGame.gameScore > 0 {
//            player?.wins += 1
//        } else {
//            player?.losses += 1
//        }
//        player?.playerGames.insert(playerGame, at: 0)
//
//        if let newRating = newRating {
//            player?.rating = newRating
//        }else{
//            let rating = Rating(mean: (player?.rating.Mean)! + playerGame.gameScore, standardDeviation: (player?.rating.StandardDeviation)! + playerGame.sigmaChange)
//
//            player?.rating = rating
//        }
//    }
//
//    func remove(player: PlayerForm) {
//        assert(false)
//
////        Database.database().reference(withPath: "leagues/\(league.id)/players/\(player.id)").removeValue() { error, ref in
////            if let error = error {
////                errorFound = error
////            }
////            league.players.removeValue(forKey: player.id)
////            league.displayNameToUserID.removeValue(forKey: player.displayName)
////            league.phoneNumberToUID.removeValue(forKey: player.phoneNumber)
////            group.leave()
////        }
////
////        storageRef.child("\(league.id)/\(player.id).jpg").delete(completion: { error in
////            // TODO ***************************
////            // FIND LOCAL IMAGE GROUP, REMOVE IMAGE FROM IT
////        })
//    }
}
