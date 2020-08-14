//
//  League.swift
//  
//
//  Created by Brice Redmond on 4/11/20.
//

import SwiftUI
import FirebaseDatabase
import FirebaseStorage

class League: Identifiable, ObservableObject {
    
    let ref: DatabaseReference?
    let id: UUID
    var players: [String : PlayerForm] = [:] // Key = PhoneNumber, Value = Player
    @Published var sortedPlayers: [PlayerForm] = []
    
    var displayNameToPhoneNumber: [String : String] = [:]
    var name: String
    @Published var leagueImage: UIImage?
    var creatorPhone: String // phone number of creator
    
    var forDisplay: Bool
    
    //convience static intializer
    static func getLeagueFromFirebase(forLeagueID leagueID: String, forDisplay: Bool, callback: @escaping (League?) -> ()) {
        let locRef = Database.database().reference(withPath: "\(leagueID)")
        locRef.observeSingleEvent(of: DataEventType.value) { (locSnapshot) in
            callback(League(snapshot: locSnapshot, id: "\(leagueID)", forDisplay: forDisplay))
        }
    }
    
    //Default init for before the real leagues have been downloaded
    init() {
        self.ref = nil
        self.id = UUID()
        self.leagueImage = UIImage()
        self.name = "No Leagues"
        self.creatorPhone = ""
        self.forDisplay = false
    }
    
    // init for first creating the league
    init(leagueName: String, id: UUID = UUID(), image: UIImage = UIImage(), creator: User, creatorDisplayName: String) {
        self.ref = nil
        self.id = id
        self.name = leagueName
        self.leagueImage = image
        self.creatorPhone = creator.phoneNumber!
        
        self.players[creatorPhone] = (PlayerForm(phoneNumber: creator.phoneNumber!, displayName: creatorDisplayName, image: creator.image, rank: 1, rating: GameInfo.DefaultGameInfo.DefaultRating, realName: creator.displayName!))
        self.displayNameToPhoneNumber[creatorDisplayName] = creatorPhone
        self.forDisplay = false
        self.rankPlayers()
    }
        
    // init for first creating league
    init(leagueName: String, id: UUID = UUID(), image: UIImage, creatorPhone: String, creatorDisplayName: String, creatorRealName: String, creatorImage: UIImage) {
        self.ref = nil
        self.id = id
        self.name = leagueName
        self.leagueImage = image
        self.creatorPhone = creatorPhone
        
        self.players[creatorPhone] = (PlayerForm(phoneNumber: creatorPhone, displayName: creatorDisplayName, image: creatorImage, rank: 1, rating: GameInfo.DefaultGameInfo.DefaultRating, realName: creatorRealName))
        self.displayNameToPhoneNumber[creatorDisplayName] = creatorPhone
        self.forDisplay = false
        self.rankPlayers()
//        self.players[creator.phoneNumber!]!.playerGames.append(Game(team1: ["+16506693169", "+16505553434"], team2: ["+16505551234", "+16505554321"], scores: ["12", "5"], gameScore: -1.5))
        //runAlgorithm()
    }
    
    //init from firebase
    init?(snapshot: DataSnapshot, id: String, forDisplay: Bool) {
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
        self.forDisplay = forDisplay
        if forDisplay {
            getPlayersSorted(value["players"] as? NSDictionary)
            getImage()
        }
    }
    
    func returnPlayers() -> [PlayerForm] {
        return Array(self.players.values)
    }
    
    func getPlayersSorted(_ playersDict: NSDictionary?) {
        
        guard let playersDict = playersDict else {
            print("failed in playersDict")
            return
        }

        for each in playersDict {
            getPlayer(each.key as? String, each.value as? NSDictionary)
        }
        
        rankPlayers()
    }
    
    func rankPlayers() {
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
        
        sortedPlayers = Array(players.values).sorted()
    }
    
    func getPlayer(_ phoneNumber: String?, _ playerDict: NSDictionary?) {
        guard let playerDict = playerDict, let phoneNumber = phoneNumber, let mu = playerDict["mu"] as? Double, let sigma = playerDict["sigma"] as? Double else {
            print("failed in playerDict")
            return
        }

        //let p = PlayerForm(phoneNumber: phoneNumber, displayName: playerDict["displayName"] as! String, rank: 1, rating: Rating(mean: mu, standardDeviation: sigma), playerGames: [], realName: playerDict["realName"] as! String)
        
        let p = PlayerForm(phoneNumber: phoneNumber, displayName: playerDict["displayName"] as! String, rank: 1, rating: GameInfo.DefaultGameInfo.DefaultRating, playerGames: [], realName: playerDict["realName"] as! String)
        self.players[phoneNumber] = p

        if forDisplay {
            let pair = getGames(playerDict["games"] as? NSDictionary, player: p)
            if let pair = pair {
                p.setGamesInfo(rivals: pair.0, bestTeammates: pair.1)
            }
            p.getImage(leagueID: id.uuidString)
        }
        
        self.displayNameToPhoneNumber[playerDict["displayName"] as! String] = phoneNumber
       
    }

    func getGames(_ gamesDict: NSDictionary?, player: PlayerForm) -> ([String: Double], [String: Double])? {

        player.rating = GameInfo.DefaultGameInfo.DefaultRating

        guard let gamesDict = gamesDict else {
           print("failed in getGames")
           return nil
       }
        
        var rivals: [String: Double] = [:]
        var bestTeammates: [String: Double] = [:]
            
        var mu = 0.0
        var sigma = 0.0
        
        for each in gamesDict as NSDictionary {
            if let val = each.value as? NSDictionary {
                if let game = Game(gameDict: val, date: each.key as! String) {
                    if game.team1.contains(player.phoneNumber) || game.team1.contains(player.displayName) {
                        addToRivalsAndTeammates(playerTeammates: game.team1.filter({$0 != player.displayName}), otherTeam: game.team2, &rivals, &bestTeammates, game.gameScore)
                    }else{
                        addToRivalsAndTeammates(playerTeammates: game.team2.filter({$0 != player.displayName}), otherTeam: game.team1, &rivals, &bestTeammates, game.gameScore)
                    }
                    
                    mu += game.gameScore
                    sigma += game.sigmaChange
                    addPlayerGame(forPlayerPhone: player.phoneNumber, playerGame: game, newRating: nil)
                }
            }
        }
        
//        player.rating = Rating(mean: player.rating.Mean + mu, standardDeviation: player.rating.StandardDeviation + sigma)
        player.playerGames.sort(by: {Int($0.date)! > Int($1.date)!})
        
        return (rivals, bestTeammates)
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
            playersDict[player.key] = player.value.toAnyObject() as AnyObject
        }
        
        retVal["players"] = playersDict as AnyObject
        
        retVal["creatorPhone"] = creatorPhone as AnyObject
        
        return retVal
    }
    
    func changePlayerDisplayName(phoneNumber: String, newDisplayName: String, callback: @escaping (Bool, String) -> ()) {
        
        self.players[phoneNumber]?.changeDisplayName(newDisplayName: newDisplayName, leagueID: self.id.uuidString, callback: { success, errorMessage in
            if success {
                self.displayNameToPhoneNumber[newDisplayName] = phoneNumber
            }
            callback(success, errorMessage)
        })
    }
    
    
    func changeRealName(forPlayerPhone phoneNumber: String, newName: String) {
        Database.database().reference(withPath: "\(self.id)/players/\(phoneNumber)/realName").setValue(newName) { (error, ref) -> Void in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.players[phoneNumber]?.realName = newName
            }
        }
    }
    
    func changePlayerImage(player: PlayerForm, newImage: UIImage, callback: @escaping (Bool) -> ()) {
        let imageRef = Storage.storage().reference().child("\(self.id)\(player.phoneNumber).jpg")
        StorageService.uploadImage(newImage, at: imageRef) { (downloadURL) in
            guard let _ = downloadURL else {
                callback(false)
                return
            }
            callback(true)
        }
    }
    
    func getRealName(fromDisplayName displayName: String) -> String? {
        print("----")
        print(displayName)
        for player in players {
            print(player.value.displayName)
        }
        
        if let realName = players[displayNameToPhoneNumber[displayName] ?? ""]?.realName {
            return realName
        } else {
            return nil
        }
        
    }
    
    func addPlayerGame(forPlayerPhone phone: String, playerGame: Game, newRating: Rating?) {
        let player = players[phone]
        
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
    
    func deleteGame(forDate date: String, forPlayer player: PlayerForm) -> [[Game]] {
        // for each player, move their games into a dictionary. Depending on the number of players per team, there can be multiple of the same game. The dictionary will take care of this.
        var allGamesAfterDate: [Int: Game] = [:]
        for player in players.values {
            //get their initial ratings
            var mean = player.rating.Mean
            var sigma = player.rating.StandardDeviation
            while let game = player.playerGames.first, Int(game.date)! > Int(date)! {
                //bubble back each time to get back to the original game
                mean -= game.gameScore
                sigma -= game.sigmaChange
                allGamesAfterDate[Int(game.date)!] = game
                player.playerGames.removeFirst()
                if game.gameScore > 0 {
                   player.wins -= 1
               } else{
                   player.losses -= 1
               }
            }
            
            if let game = player.playerGames.first, game.date == date && (game.team1.contains(player.displayName) || game.team2.contains(player.displayName)) {
                mean -= game.gameScore
                sigma -= game.sigmaChange
                player.playerGames.removeFirst() // remove the actual game but dont add it to allgamesafterdate
                if game.gameScore > 0 {
                    player.wins -= 1
                } else{
                    player.losses -= 1
                }
            }
            
            //set the player rating to whatever it was before this game
            player.rating = Rating(mean: mean, standardDeviation: sigma)
        }
        
        return calculateRankingsFromDictionary(allGamesAfterDate)
    }
    
    func calculateRankingsFromDictionary(_ allGamesAfterDate: [Int: Game]) -> [[Game]] {
        var gamesToUpload: [[Game]] = []
        //iterate through all the games, calculating the new rankings
        for (_, value) in allGamesAfterDate.sorted(by: { $0.0 < $1.0 }) {
            let playerStringArr = value.team1 + value.team2
            let newRatings = Functions.getNewRatings(players: playerStringArr, scores: value.scores, ratings: [players[displayNameToPhoneNumber[value.team1[0]]!]!.rating, players[displayNameToPhoneNumber[value.team1[1]]!]!.rating, players[displayNameToPhoneNumber[value.team2[0]]!]!.rating, players[displayNameToPhoneNumber[value.team2[1]]!]!.rating])
            
            var games: [Game] = []
            for i in 0..<newRatings.count {
                let playerPhone = displayNameToPhoneNumber[playerStringArr[i]]!
                let oldPlayerMean = players[playerPhone]!.rating.Mean
                let oldPlayerSigma = players[playerPhone]!.rating.StandardDeviation
                let game = Game(team1: value.team1, team2: value.team2, scores: value.scores, gameScore: newRatings[i].Mean - oldPlayerMean, sigmaChange: newRatings[i].StandardDeviation - oldPlayerSigma, date: value.date)
                games.append(game)
                addPlayerGame(forPlayerPhone: playerPhone, playerGame: game, newRating: newRatings[i])
            }
            
            gamesToUpload.append(games)
            
        }
        
        for player in players.values {
            player.playerGames.sort(by: {Int($0.date)! > Int($1.date)!})
        }
        
        self.rankPlayers()
        return gamesToUpload
    }
    
    func recalculateRankings() -> [[Game]] {
        let gameInfo = GameInfo.DefaultGameInfo
        for player in players.values {
            player.rating = gameInfo.DefaultRating
        }
        
        var allGamesAfterDate: [Int: Game] = [:]
        for player in players.values {
            for game in player.playerGames {
                allGamesAfterDate[Int(game.date)!] = game
            }
            player.playerGames = []
            player.wins = 0
            player.losses = 0
        }
        
        return calculateRankingsFromDictionary(allGamesAfterDate)
    }
}
