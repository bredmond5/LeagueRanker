////
////  LeagueLocal+CoreDataProperties.swift
////
////
////  Created by Brice Redmond on 9/13/20.
////
////
//
//import CoreData
//import FirebaseDatabase
//
//extension LeagueLocal {
//
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<LeagueLocal> {
//        return NSFetchRequest<LeagueLocal>(entityName: "LeagueLocal")
//    }
//
//    @NSManaged public var id: UUID
//    @NSManaged public var playersLocal: NSSet?
//    @NSManaged public var blockedPlayers: NSSet?
//    @NSManaged public var leagueSettings: LeagueSettingsLocal
//    @NSManaged public var downloaded: Bool
//
//    public var sortedPlayers: [PlayerLocal] {
//        let set = playersLocal as? Set<PlayerLocal> ?? []
//        return set.sorted {
//            if !$0.moreGames(than: leagueSettings.numPlacements) && !$1.moreGames(than: leagueSettings.numPlacements) {
//                return $0.wins + $0.losses > $1.wins + $1.losses
//            } else if !$0.moreGames(than: leagueSettings.numPlacements) {
//                return false
//            } else if !$1.moreGames(than: leagueSettings.numPlacements) {
//                return true
//            }
//            return $0.mean > $1.mean
//        }
//    }
//
//    public var ref: DatabaseReference {
//        return Database.database().reference(withPath: "leagues/\(self.id)")
//    }
//
//    public func getRealtimePath() -> String {
//        return "leagues/\(self.id)"
//    }
//
//    public func unDownload(managedObjectContext: NSManagedObjectContext) {
//        // need to detach listeners
//        if let p = playersLocal as? Set<NSManagedObject> {
//            for playerLocal in p {
//                managedObjectContext.delete(playerLocal)
//            }
//        }
//
//        if let b = blockedPlayers as? Set<NSManagedObject> {
//            for blockedPlayer in b {
//                managedObjectContext.delete(blockedPlayer)
//            }
//        }
//    }
//
//    public func opened(context: NSManagedObjectContext, completion: @escaping (Error?) -> ()) {
//
//        leagueSettings.dateLastOpened = Int64(Date().timeIntervalSince1970 * 1000)
//
//        if downloaded {
//            // maybe should check all the player image shits, but maybe there are already listeners on everything
//            completion(nil)
//            return
//        }
//
//        leagueSettings.listen(to: ref.child("leagueSettings"), completion: { error in
//            print("league settings initialized")
//        })
//
//        listenToPlayers()
//        listenToGames()
//
//
//
//
//
//            self?.leagueSettings.setValues(to: leagueSettings, completion: { error in
//                if let error = error {
//                    print(error)
//                }
//            })
//
//            self?.getPlayersSorted(context: context, players)
//            self?.getBlockedPlayers(context: context, value["blockedUsers"] as? NSDictionary)
//            self?.getGames(value["games"] as? NSDictionary)
//
//            self?.rankPlayers()
//            self?.getImages()
//
//
//    }
//
//    func listenToPlayers() {
//        ref.child("players").observeSingleEvent(of: .value, with: { snapshot in // this is not right because it will pull all the players games
//
//        })
//    }
//
//    func listenToBlockedPlayers() {
//        ref.child("blockedUsers").observeSingleEvent(of: .value, with: { snapshot in
//
//        })
//    }
//
//    func listenToGames() {
//        ref.child("games").observeSingleEvent(of: .value, with: { snapshot in
//
//        })
//    }
//
//    func getBlockedPlayers(context: NSManagedObjectContext, _ value: NSDictionary?) {
//        guard let blockedUIDs = value else {
//            print("No blocked users")
//            return
//        }
//
//        for each in blockedUIDs {
//            if let blockUID = each.value as? NSArray {
//                let blockedPlayer = BlockedPlayer(context: context)
//                blockedPlayer.setValues(to: blockUID, id: each.key as? String)
//                blockedPlayer.leagueLocal = self
//            }
//        }
//    }
//
//    func getPlayersSorted(context: NSManagedObjectContext, _ playersDict: NSDictionary) {
//
//        for each in playersDict {
//            let player = PlayerLocal(context: context)
//            player.setValues(to: each.value as? NSDictionary, uid: each.key as? String, completion: { error in
//                if let error = error {
//                    print(error.localizedDescription)
//                }
//                player.leagueLocal = self
//
//            })
//            //        self.phoneNumberToUID[phoneNumber] = uid
//            //        self.displayNameToUserID[displayName] = uid
//        }
//    }
//
//    func rankPlayers() {
//        let playerArr = sortedPlayers
//        
//        var count = 0
//        playerArr[0].rank = 1
//
//        for i in 1..<playerArr.count {
//            if round(playerArr[i].mean * 100) / 100 < round(playerArr[i-1].mean * 100) / 100 || (!playerArr[i].moreGames(than: leagueSettings.numPlacements) && playerArr[i-1].moreGames(than: leagueSettings.numPlacements)){
//                count = i
//            }
//            playerArr[i].rank = Int64(count + 1)
//        }
//        // need a save context
//    }
//
//    func getGames(_ gamesDict: NSDictionary?) {
//        guard let gamesDict = gamesDict else {
//           print("No games")
//           return
//        }
//
//        for each in gamesDict {
//            if let val = each.value as? NSDictionary {
//                if let game = Game(gameDict: val, id: UUID(uuidString: each.key as! String)!) {
//                    self.leagueGames.insert(game, at: 0)
//                }
//            }
//        }
//
//        leagueGames.sort(by: >)
//        for game in leagueGames.reversed() {
//            addGame(game)
//        }
//    }
//
//    func addGameFromGameForm(_ overallGame: Game, ratingsFromFirebase: [String: Rating]) {
//        self.leagueGames.insert(overallGame, at: 0)
//        leagueGames.sort(by: >)
//        for (key, value) in ratingsFromFirebase {
//            players[key]?.rating = value
//        }
//        addGame(overallGame)
//    }
//
//    func addGame(_ overallGame: Game, completion: (([Game]) -> Void)? = nil) {
//        var games: [Game] = []
//        let playerUIDs = overallGame.team1 + overallGame.team2
//
//        let newRatings = Functions.getNewRatings(players: playerUIDs, scores: overallGame.scores, ratings: [players[playerUIDs[0]]!.rating, players[playerUIDs[1]]!.rating, players[playerUIDs[2]]!.rating, players[playerUIDs[3]]!.rating])
//
//        for i in 0..<playerUIDs.count {
//            let uid = playerUIDs[i]
//            let oldPlayerMean = players[uid]!.rating.Mean
//            let oldPlayerSigma = players[uid]!.rating.StandardDeviation
//            let game = PlayerGame(game: overallGame, gameScore: newRatings[i].Mean - oldPlayerMean, sigmaChange: newRatings[i].StandardDeviation - oldPlayerSigma)
//            games.append(game)
//            addPlayerGame(forPlayerUID: uid, playerGame: game, newRating: newRatings[i])
//        }
//
//        completion?(games)
//    }
//
//    func addToRivalsAndTeammates(playerTeammates: [String], otherTeam: [String], _ rivals: inout [String: Double], _ bestTeammates: inout [String: Double], _ gameScore: Double) {
//        for p in otherTeam {
//            if var rival = rivals[p] {
//                rival += gameScore
//            } else {
//                rivals[p] = gameScore
//            }
//
//        }
//        for teammate in playerTeammates {
//            if var teammate = bestTeammates[teammate] {
//                teammate += gameScore
//            }else{
//                bestTeammates[teammate] = gameScore
//            }
//        }
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
//
//    }
//
//    func toAnyObject() -> Any {
//        var retVal = [String : AnyObject]()
//        retVal["leagueName"] = self.name as AnyObject
//
//        var playersDict = [String : AnyObject]()
//        for player in players {
//            playersDict[player.key] = player.value.toAnyObject() as AnyObject
//        }
//
//        retVal["players"] = playersDict as AnyObject
//
//        var gamesDict = [String : AnyObject]()
//        for game in leagueGames {
//            gamesDict[game.id.uuidString] = game.toAnyObject() as AnyObject
//        }
//
//        retVal["games"] = gamesDict as AnyObject
//
//        retVal["creatorUID"] = creatorUID as AnyObject
//
//        return retVal
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
//    func changeLeagueImage(newImage: UIImage, callback: @escaping (Bool) -> ()) {
//        let imageRef = Storage.storage().reference().child("\(self.id)/\(self.id).jpg")
//        StorageService.uploadImage(newImage, at: imageRef) { (downloadURL) in
//            guard let _ = downloadURL else {
//                callback(false)
//                return
//            }
//            self.leagueImage = newImage
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
////    func deleteGame(forDate date: String, forPlayer player: PlayerForm, callback: @escaping ([Game]) -> ()) {
////        League.getLeagueFromFirebase(forLeagueID: self.id.uuidString, forDisplay: false, shouldGetGames: true, callback: { league in
////            if let league = league {
////                var allGamesAfterDate: [Int: Game] = [:]
////                for player in league.players.values {
////                    //get their initial ratings
////                    var mean = player.rating.Mean
////                    var sigma = player.rating.StandardDeviation
////                    while let game = player.playerGames.first, Int(game.date)! > Int(date)! {
////                        //bubble back each time to get back to the original game
////                        mean -= game.gameScore
////                        sigma -= game.sigmaChange
////                        allGamesAfterDate[Int(game.date)!] = game
////                        player.playerGames.removeFirst()
////                        if game.gameScore > 0 {
////                           player.wins -= 1
////                       } else{
////                           player.losses -= 1
////                       }
////                    }
////
////                    if let game = player.playerGames.first, game.date == date && (game.team1.contains(player.id) || game.team2.contains(player.id)) {
////                        mean -= game.gameScore
////                        sigma -= game.sigmaChange
////                        player.playerGames.removeFirst() // remove the actual game but dont add it to allgamesafterdate
////                        if game.gameScore > 0 {
////                            player.wins -= 1
////                        } else{
////                            player.losses -= 1
////                        }
////                    }
////
////                    self.players[player.id]?.rating = Rating(mean: mean, standardDeviation: sigma)
////                    self.players[player.id]?.playerGames = player.playerGames
////                    self.players[player.id]?.wins = player.wins
////                    self.players[player.id]?.losses = player.losses
////
////                    //set the player rating to whatever it was before this game
//////                    player.rating = Rating(mean: mean, standardDeviation: sigma)
////                }
////                //callback(self.calculateRankingsFromDictionary(allGamesAfterDate))
////            }
////        })
////    }
//
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
//}
//
//// MARK: Generated accessors for playerLocal
//extension LeagueLocal {
//
//    @objc(addPlayerLocalObject:)
//    @NSManaged public func addToPlayerLocal(_ value: PlayerLocal)
//
//    @objc(removePlayerLocalObject:)
//    @NSManaged public func removeFromPlayerLocal(_ value: PlayerLocal)
//
//    @objc(addPlayerLocal:)
//    @NSManaged public func addToPlayerLocal(_ values: NSSet)
//
//    @objc(removePlayerLocal:)
//    @NSManaged public func removeFromPlayerLocal(_ values: NSSet)
//
//}
