//
//  League.swift
//  
//
//  Created by Brice Redmond on 4/11/20.
//

import SwiftUI
import FirebaseDatabase
import FirebaseStorage

class League: Identifiable, ObservableObject, Equatable {
    static func == (lhs: League, rhs: League) -> Bool { // this could use some work probably
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.creatorUID == rhs.creatorUID
    }
    
    let ref: DatabaseReference?
    let id: UUID
    var players: [String : PlayerForm] = [:] {
        didSet {
            sortedPlayers = Array(players.values).sorted()
        }
    }// Key = uid, Value = Player
    @Published var sortedPlayers: [PlayerForm] = []
    
    var phoneNumberToUID: [String: String] = [:]
    var displayNameToUserID: [String : String] = [:]
    @Published var name: String
    @Published var leagueImage: UIImage?
    var creatorUID: String // uid of creator
    var leagueGames: [Game] = []
    
    var forDisplay: Bool
    let numPlacements: Int
    
    var blockedPlayers: [String: [String]] //uid : [displayName, phonenumber, realName]
    
    //convience static intializer
    static func getLeagueFromFirebase(forLeagueID leagueID: String, forDisplay: Bool, shouldGetGames: Bool, callback: @escaping (League?) -> ()) {
        let locRef = Database.database().reference(withPath: "leagues/\(leagueID)")
        locRef.observeSingleEvent(of: DataEventType.value, with: { (locSnapshot) in
            callback(League(snapshot: locSnapshot, forDisplay: forDisplay, shouldGetGames: shouldGetGames))
        }) { (error) in
            callback(nil)
        }
    }
    
    static func getLeague(fromSnapshot snapshot: DataSnapshot, forDisplay: Bool, shouldGetGames: Bool, completion: (League?) -> ()) {
        completion(League(snapshot: snapshot, forDisplay: forDisplay, shouldGetGames: shouldGetGames))
    }
    
    //Default init for when we need to force swift to reload the page
    init() {
        self.ref = nil
        self.id = UUID()
        self.leagueImage = UIImage()
        self.name = "No Leagues"
        self.creatorUID = ""
        self.forDisplay = false
        self.numPlacements = 15
        self.blockedPlayers = [:]
    }
        
    // init for first creating league
    init(leagueName: String, id: UUID = UUID(), image: UIImage, creator: User, creatorDisplayName: String, creatorImage: UIImage, numPlacements: Int) {
        self.ref = nil
        self.id = id
        self.name = leagueName
        self.leagueImage = image
        self.creatorUID = creator.uid
        self.numPlacements = numPlacements
        self.players[creatorUID] = (PlayerForm(uid: creatorUID, displayName: creatorDisplayName, image: creatorImage, rank: 1, rating: GameInfo.DefaultGameInfo.DefaultRating, realName: creator.realName!, numPlacementsRequired: numPlacements, phoneNumber: creator.phoneNumber!))
        self.displayNameToUserID[creatorDisplayName] = creatorUID
        self.forDisplay = false
        self.blockedPlayers = [:]
        self.rankPlayers()
    }
    
    //init from firebase
    init?(snapshot: DataSnapshot, forDisplay: Bool, shouldGetGames: Bool) {
       guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["leagueName"] as? String,
            let creatorUID = value["creatorUID"] as? String,
            let players = value["players"] as? NSDictionary,
            
            let id = UUID(uuidString: snapshot.key)
           else {
                print("Failed in league snapshot initializer")
                return nil
           }
        
        self.ref = snapshot.ref
        self.name = name
        self.creatorUID = creatorUID
        self.id = id
        self.forDisplay = forDisplay
        self.numPlacements = 5
        
        self.blockedPlayers = [:]
        if let blockedUIDs = value["blockedUsers"] as? NSDictionary {
            for each in blockedUIDs {
                if let blockUID = each.value as? NSArray {
                    let playerArr = [blockUID[0] as! String, blockUID[1] as! String, blockUID[2] as! String]
                    self.blockedPlayers[each.key as! String] = playerArr
                }
            }
        }
        
        getPlayersSorted(players, shouldGetGames: shouldGetGames)
        
        if shouldGetGames {
            getGames(value["games"] as? NSDictionary)
        }
        
        if forDisplay {
            rankPlayers()
            getImages()
        }
    }
    
    func returnPlayers() -> [PlayerForm] {
        return Array(self.players.values)
    }
    
    func getPlayersSorted(_ playersDict: NSDictionary?, shouldGetGames: Bool) {
        
        guard let playersDict = playersDict else {
            print("failed in getPlayersSorted")
            return
        }

        for each in playersDict {
            getPlayer(each.key as? String, each.value as? NSDictionary, shouldGetGames: shouldGetGames)
        }
    }
    
    func rankPlayers() {
        var playerArr = returnPlayers()
        playerArr.sort()
        
        var count = 0
        players[playerArr[0].id]!.rank = 1
        
        for i in 1..<playerArr.count {
            if round(playerArr[i].rating.Mean * 100) / 100 < round(playerArr[i-1].rating.Mean * 100) / 100 || (!playerArr[i].enoughGames() && playerArr[i-1].enoughGames()){
                count = i
            }
            players[playerArr[i].id]!.rank = count + 1
        }
        
        sortedPlayers = Array(players.values).sorted()
    }
    
    func getPlayer(_ uid: String?, _ playerDict: NSDictionary?, shouldGetGames: Bool) {
        guard let playerDict = playerDict,
            let uid = uid,
            let mu = playerDict["mu"] as? Double,
            let sigma = playerDict["sigma"] as? Double,
            let displayName =  playerDict["displayName"] as? String,
            let realName = playerDict["realName"] as? String,
            let phoneNumber = playerDict["phoneNumber"] as? String
            
            else {
            print("failed in playerDict")
            return
        }

        //let p = PlayerForm(phoneNumber: phoneNumber, displayName: playerDict["displayName"] as! String, rank: 1, rating: Rating(mean: mu, standardDeviation: sigma), playerGames: [], realName: playerDict["realName"] as! String)
        
        let p = PlayerForm(uid: uid, displayName: displayName, rank: 1, rating: GameInfo.DefaultGameInfo.DefaultRating, playerGames: [], realName: realName, numPlacementsRequired: self.numPlacements, phoneNumber: phoneNumber)
        self.players[uid] = p

//            let pair = getGames(playerDict["games"] as? NSDictionary, player: p)
//            if let pair = pair {
//                p.setGamesInfo(rivals: pair.0, bestTeammates: pair.1)
//            }
        
        
        self.phoneNumberToUID[phoneNumber] = uid
        self.displayNameToUserID[displayName] = uid
       
    }
    
    func getGames(_ gamesDict: NSDictionary?) {
        guard let gamesDict = gamesDict else {
           print("failed in getGames")
           return
        }
        
        for each in gamesDict {
            if let val = each.value as? NSDictionary {
                if let game = Game(gameDict: val, id: UUID(uuidString: each.key as! String)!) {
                    self.leagueGames.insert(game, at: 0)
                }
            }
        }
        leagueGames.sort(by: >)
        for game in leagueGames.reversed() {
            addGame(game)
        }
    }
    
    func addGameFromGameForm(_ overallGame: Game, ratingsFromFirebase: [String: Rating]) {
        self.leagueGames.insert(overallGame, at: 0)
        leagueGames.sort(by: >)
        for (key, value) in ratingsFromFirebase {
            players[key]?.rating = value
        }
        addGame(overallGame)
    }
    
    func addGame(_ overallGame: Game, completion: (([Game]) -> Void)? = nil) {
        var games: [Game] = []
        let playerUIDs = overallGame.team1 + overallGame.team2

        let newRatings = Functions.getNewRatings(players: playerUIDs, scores: overallGame.scores, ratings: [players[playerUIDs[0]]!.rating, players[playerUIDs[1]]!.rating, players[playerUIDs[2]]!.rating, players[playerUIDs[3]]!.rating])
        
        for i in 0..<playerUIDs.count {
            let uid = playerUIDs[i]
            let oldPlayerMean = players[uid]!.rating.Mean
            let oldPlayerSigma = players[uid]!.rating.StandardDeviation
            let game = PlayerGame(game: overallGame, gameScore: newRatings[i].Mean - oldPlayerMean, sigmaChange: newRatings[i].StandardDeviation - oldPlayerSigma)
            games.append(game)
            addPlayerGame(forPlayerUID: uid, playerGame: game, newRating: newRatings[i])
        }
        
        completion?(games)
    }
    
    func addToRivalsAndTeammates(playerTeammates: [String], otherTeam: [String], _ rivals: inout [String: Double], _ bestTeammates: inout [String: Double], _ gameScore: Double) {
        for p in otherTeam {
            if var rival = rivals[p] {
                rival += gameScore
            } else {
                rivals[p] = gameScore
            }
        
        }
        for teammate in playerTeammates {
            if var teammate = bestTeammates[teammate] {
                teammate += gameScore
            }else{
                bestTeammates[teammate] = gameScore
            }
        }
    }
    
    func getImages() {
        let r = Storage.storage().reference().child("\(id)")
        let myGroup = DispatchGroup()

        myGroup.enter()
        r.listAll(completion: { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            for _ in 0..<result.items.count {
                myGroup.enter()
            }
            myGroup.leave()

            result.items.forEach({ imageRef in
                imageRef.getData(maxSize: 1 * 1024 * 1024, completion: { data, error in
                    if let error = error {
                        print("League folder image error: \(error.localizedDescription)")
                    } else {
                        let id = String(imageRef.name.split(separator: ".")[0])
                       
                        if let player = self.players[id] {
                            player.image =  UIImage(data: data!) ?? Constants.defaultPlayerPhoto
                            
                        } else if id == self.id.uuidString {
                            self.leagueImage = UIImage(data: data!) ?? Constants.defaultLeaguePhoto
                            
                        }
                    }
                    myGroup.leave()
                })
            })
        })
        
        myGroup.notify(queue: .main) {
            for player in self.players.values {
                if player.image == nil {
                    player.image = Constants.defaultPlayerPhoto
                }
            }
            if self.leagueImage == nil {
                self.leagueImage = Constants.defaultLeaguePhoto
            }
        }
        
        
    }
    
    func toAnyObject() -> Any {
        var retVal = [String : AnyObject]()
        retVal["leagueName"] = self.name as AnyObject
        
        var playersDict = [String : AnyObject]()
        for player in players {
            playersDict[player.key] = player.value.toAnyObject() as AnyObject
        }
        
        retVal["players"] = playersDict as AnyObject
        
        var gamesDict = [String : AnyObject]()
        for game in leagueGames {
            gamesDict[game.id.uuidString] = game.toAnyObject() as AnyObject
        }
        
        retVal["games"] = gamesDict as AnyObject
        
        retVal["creatorUID"] = creatorUID as AnyObject
        
        return retVal
    }
    
    func changePlayerDisplayName(uid: String, newDisplayName: String, callback: @escaping (Error?) -> ()) {
        
        self.players[uid]?.changeDisplayName(newDisplayName: newDisplayName, leagueID: self.id.uuidString, callback: { error in
            if let error = error {
                callback(error)
                return
            }
            self.displayNameToUserID[newDisplayName] = uid
            callback(nil)
        })
    }
    
    
    func changeRealName(forUID uid: String, newName: String, completion: ((Error?) -> Void)? = nil) {
        Database.database().reference(withPath: "leagues/\(self.id)/players/\(uid)/realName").setValue(newName) { (error, ref) -> Void in
            if let error = error {
                print(error.localizedDescription)
                completion?(error)
            } else {
                self.players[uid]?.realName = newName
                completion?(nil)
            }
        }
    }
    
    func changePlayerImage(player: PlayerForm, newImage: UIImage, callback: @escaping (Bool) -> ()) {
        let imageRef = Storage.storage().reference().child("\(self.id)/\(player.id).jpg")
        StorageService.uploadImage(newImage, at: imageRef) { (downloadURL) in
            guard let _ = downloadURL else {
                callback(false)
                return
            }
            callback(true)
        }
    }
    
    func changeLeagueImage(newImage: UIImage, callback: @escaping (Bool) -> ()) {
        let imageRef = Storage.storage().reference().child("\(self.id)/\(self.id).jpg")
        StorageService.uploadImage(newImage, at: imageRef) { (downloadURL) in
            guard let _ = downloadURL else {
                callback(false)
                return
            }
            self.leagueImage = newImage
            callback(true)
        }
    }
    
    func addPlayerGame(forPlayerUID uid: String, playerGame: PlayerGame, newRating: Rating?) {
        let player = players[uid]
        
        if playerGame.gameScore > 0 {
            player?.wins += 1
        } else {
            player?.losses += 1
        }
        player?.playerGames.insert(playerGame, at: 0)
        
        if let newRating = newRating {
            player?.rating = newRating
        }else{
            let rating = Rating(mean: (player?.rating.Mean)! + playerGame.gameScore, standardDeviation: (player?.rating.StandardDeviation)! + playerGame.sigmaChange)
            
            player?.rating = rating
        }
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
    
    func calculateRankingsFromDictionary(_ allGamesAfterDate: [Int: Game]) -> [[Game]] {
        var gamesToUpload: [[Game]] = []
        //iterate through all the games, calculating the new rankings
        for (_, value) in allGamesAfterDate.sorted(by: { $0.0 < $1.0 }) {
            addGame(value, completion: { games in
                gamesToUpload.append(games)
            })
        }
        
        for player in players.values {
            player.playerGames.sort(by: {$0.date > $1.date})
        }
        
        self.rankPlayers()
        return gamesToUpload
    }
    
//    func recalculateRankings(callback: @escaping ([Game]) -> ()) {
//        // pull the league so that can get any new games just in case
//        League.getLeagueFromFirebase(forLeagueID: self.id.uuidString, forDisplay: false, shouldGetGames: true, callback: { league in
//            if let league = league {
//                //reset the rankings
//                let gameInfo = GameInfo.DefaultGameInfo
//                for player in self.players.values {
//                    player.rating = gameInfo.DefaultRating
//                    player.playerGames = []
//                    player.wins = 0
//                    player.losses = 0
//                }
//                
//                let games = league.leagueGames
//                
//                var allGamesAfterDate: [Int: Game] = [:]
//                for player in league.players.values {
//                    // get all the games from the online league
//                   for game in player.playerGames {
//                       allGamesAfterDate[Int(game.date)!] = game
//                   }
//               }
//            }
//        })
//    }
    
    func setValues(toOtherLeague league: League) {
        self.leagueGames = league.leagueGames
        self.phoneNumberToUID = league.phoneNumberToUID
        self.displayNameToUserID = league.displayNameToUserID
        self.blockedPlayers = league.blockedPlayers
        let otherPlayers = league.players
        
        for (key, player) in self.players {
            player.setValues(toOtherPlayer: otherPlayers[key] ?? player)
        }
    }
    
//    func returnGamesWithUserIDs(callback: @escaping ([[Game]]) -> ()) {
//        abort()
//        League.getLeagueFromFirebase(forLeagueID: self.id.uuidString, forDisplay: false, shouldGetGames: true, callback: { league in
//            if let league = league {
//                let gameInfo = GameInfo.DefaultGameInfo
//                for player in self.players.values {
//                    player.rating = gameInfo.DefaultRating
//                }
//
//                var allGamesAfterDate: [Int: Game] = [:]
//                for player in league.players.values {
//                    // get all the games from the online league
//                   for game in player.playerGames {
//                       allGamesAfterDate[Int(game.date)!] = game
//                   }
//                    //reset our actual league values
//                    self.players[player.id]?.playerGames = []
//                    self.players[player.id]?.wins = 0
//                    self.players[player.id]?.losses = 0
//               }
//
//                var allGamesAfterDateCorrected: [Int: Game] = [:]
//
//                for (key, value) in allGamesAfterDate {
//                    let team1 = [self.displayNameToUserID[value.team1[0]] ?? value.team1[0], self.displayNameToUserID[value.team1[1]] ?? value.team1[1]]
//                    let team2 = [self.displayNameToUserID[value.team2[0]] ?? value.team2[0], self.displayNameToUserID[value.team2[1]] ?? value.team2[1]]
//                    let gameCorrected = Game(team1: team1, team2: team2, scores: value.scores, gameScore: value.gameScore, sigmaChange: value.sigmaChange, date: value.date, inputter: value.inputter)
//                    allGamesAfterDateCorrected[key] = gameCorrected
//                }
//                callback(self.calculateRankingsFromDictionary(allGamesAfterDateCorrected))
//            }
//        })
//    }
}
