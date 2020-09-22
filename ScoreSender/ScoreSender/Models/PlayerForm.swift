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


class PlayerForm: Identifiable, ObservableObject, Hashable {

    @Published var displayName: String = "User"
    @Published var phoneNumber: String = ""
    @Published var rank: Int = 1
    @Published var rating: Rating = GameInfo.DefaultGameInfo.DefaultRating
    @Published var playerGames: [PlayerGame] = []
    @Published var wins: Int = 0
    @Published var losses: Int = 0
    @Published var realName: String = "John"
    @Published var dbImage: DBImage
    @Published var refresher: Bool = false

    var id: String
    let ref: DatabaseReference

    var firstRead = true
    var changed: ((String, String, String) -> ())?

//    var rivals: [String: Double] = [:]
//    var bestTeammates: [String: Double] = [:]

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PlayerForm, rhs: PlayerForm) -> Bool {

        return lhs.id == rhs.id
    }

//    init(ref: DatabaseReference, leagueID: String, uid: String, displayName: String, image: UIImage? = nil, rank: Int = 1, rating: Rating, playerGames: [PlayerGame] = [], realName: String, numPlacementsRequired: Int, phoneNumber: String, creatorID: String? = nil) {
//        id = uid
////        self.phoneNumber = phoneNumber
//        self.ref = ref
//        self.displayName = displayName
//        self.dbImage = DBImage(defaultImage: image ?? Constants.defaultPlayerPhoto, dateRef: ref.child("icDate"), storagePath: "\(leagueID)/\(uid).jpg")
//        self.rank = rank
//        self.rating = rating
//        self.playerGames = playerGames
//        self.realName = realName
//        self.numPlacementsRequired = numPlacementsRequired
//        self.phoneNumber = phoneNumber
//    }

    init(ref: DatabaseReference, leagueID: String) {
        self.id = ref.key!
        self.dbImage = DBImage(defaultImage: Constants.defaultPlayerPhoto, dateRef: ref.child("icDate"), storagePath: "\(leagueID)/\(id).jpg")
        self.ref = ref
        self.dbImage.refreshRequired = { [weak self] in
            self?.refresher = false
        }

        observePlayer()
    }

    func observePlayer() {
        ref.child("values").observe(.value) { [weak self] snapshot in
            guard let playerDict = snapshot.value as? NSDictionary else {
                print("Failed converting playersdict")
                return
            }

            self?.buildSelf(fromDict: playerDict)
        }

        ref.child("games").queryLimited(toFirst: 20).observe(.value) { [weak self] snapshot in
            guard snapshot.exists(), let self = self, let gamesDict = snapshot.value as? NSDictionary else {
                return
            }

            self.playerGames = []

            for each in gamesDict {
                if let val = each.value as? NSDictionary {
                    guard let gameDict = val["game"] as? NSDictionary, let gameScore = val["gameScore"] as? Double, let sigmaChange = val["sigmaChange"] as? Double, let game = Game(gameDict: gameDict, id: UUID(uuidString: each.key as! String)!) else {
                        print("failure in playerGame")
                        return
                    }

                    self.playerGames.insert(PlayerGame(game: game, gameScore: gameScore, sigmaChange: sigmaChange), at: 0)
                }
            }

            self.playerGames.sort(by: >)
            self.refresher = false

        }
    }

    func buildSelf(fromDict playerDict: NSDictionary) {
        guard
            let mu = playerDict["mu"] as? Double,
            let sigma = playerDict["sigma"] as? Double,
            let displayName =  playerDict["displayName"] as? String,
            let realName = playerDict["realName"] as? String,
            let phoneNumber = playerDict["phoneNumber"] as? String,
            let wins = playerDict["wins"] as? Int,
            let losses = playerDict["losses"] as? Int

            else {
                print("failed in playerDict")
                return
        }
        self.rating = Rating(mean: mu, standardDeviation: sigma)
        self.displayName = displayName
        self.realName = realName
        self.phoneNumber = phoneNumber
        self.wins = wins
        self.losses = losses
        self.changed?(self.id, self.phoneNumber, self.displayName)
        
    }

    //for each in playersDict {
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
    //    func getImages() {
    //        let r = Storage.storage().reference().child("\(id)")
    //        let myGroup = DispatchGroup()
    //
    //        myGroup.enter()
    //        r.listAll(completion: { result, error in
    //            if let error = error {
    //                print(error.localizedDescription)
    //                return
    //            }
    //
    //            for _ in 0..<result.items.count {
    //                myGroup.enter()
    //            }
    //            myGroup.leave()
    //
    //            result.items.forEach({ imageRef in
    //                imageRef.getData(maxSize: 1 * 1024 * 1024, completion: { data, error in
    //                    if let error = error {
    //                        print("League folder image error: \(error.localizedDescription)")
    //                    } else {
    //                        let id = String(imageRef.name.split(separator: ".")[0])
    //
    //                        if let player = self.players[id] {
    //                            player.image =  UIImage(data: data!) ?? Constants.defaultPlayerPhoto
    //
    //                        } else if id == self.id.uuidString {
    //                            self.leagueImage = UIImage(data: data!) ?? Constants.defaultLeaguePhoto
    //
    //                        }
    //                    }
    //                    myGroup.leave()
    //                })
    //            })
    //        })
    //
    //        myGroup.notify(queue: .main) {
    //            for player in self.players.values {
    //                if player.image == nil {
    //                    player.image = Constants.defaultPlayerPhoto
    //                }
    //            }
    //            if self.leagueImage == nil {
    //                self.leagueImage = Constants.defaultLeaguePhoto
    //            }
    //        }
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
    //    func changeRealName(forUID uid: String, newName: String, completion: ((Error?) -> Void)? = nil) {
    //        Database.database().reference(withPath: "leagues/\(self.id)/players/\(uid)/realName").setValue(newName) { (error, ref) -> Void in
    //            if let error = error {
    //                print(error.localizedDescription)
    //                completion?(error)
    //            } else {
    //                self.players[uid]?.realName = newName
    //                completion?(nil)
    //            }
    //        }
    //    }
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

    deinit {
        print("deinitializing player")
        ref.child("values").removeAllObservers()
        ref.child("games").removeAllObservers()
    }

    func toAnyObject() -> Any {
        var playerDict = [String : AnyObject]()
        var playerValues = [String : AnyObject]()
        var games = [String: AnyObject]()

        playerValues["mu"] = rating.Mean as AnyObject
        playerValues["sigma"] = rating.StandardDeviation as AnyObject
        playerValues["displayName"] = displayName as AnyObject
        playerValues["realName"] = realName as AnyObject
        playerValues["phoneNumber"] = phoneNumber as AnyObject
        playerDict["playerValues"] = playerValues as AnyObject

        for game in self.playerGames {
            games[game.id.uuidString] = game.toAnyObject() as AnyObject
        }

        playerDict["games"] = games as AnyObject
        playerDict["icDate"] = dbImage.getImageChangeDate() as AnyObject

        return playerDict
    }

    func changeDisplayName(newDisplayName: String, leagueID: String, callback: @escaping (Error?) -> ()) {
        Database.database().reference(withPath: "leagues/\(leagueID)/players/\(id)/displayName").setValue(newDisplayName) { [weak self] (error, ref) -> Void in
            if let error = error {
                callback(error)
            } else {
                callback(nil)
                self?.displayName = newDisplayName
            }
        }
    }

//    func setGamesInfo(rivals: [String: Double], bestTeammates: [String: Double]) {
//        self.rivals = rivals
//        self.bestTeammates = bestTeammates
//    }
//

//    func setValues(toOtherPlayer player: PlayerForm) {
//        self.rating = player.rating
//        self.playerGames = player.playerGames
//        self.wins = player.wins
//        self.losses = player.losses
//        self.rank = player.rank
//    }

    func enoughGames(numPlacements: Int) -> Bool {
        return self.wins + self.losses >= numPlacements
    }
}
