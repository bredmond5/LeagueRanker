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
    
    init(leagueName: String, id: UUID = UUID(), image: UIImage = UIImage(), creator: User, creatorDisplayName: String) {
        self.ref = nil
        self.id = id
        self.name = leagueName
        self.leagueImage = image
        self.creatorPhone = creator.phoneNumber!
        
        self.players[creatorPhone] = (PlayerForm(phoneNumber: creator.phoneNumber!, displayName: creatorDisplayName, image: creator.image, rank: 1, rating: GameInfo.DefaultGameInfo.DefaultRating, realName: creator.displayName!))
        self.displayNameToPhoneNumber[creatorDisplayName] = creatorPhone
        self.rankPlayers()
    }
        
    init(leagueName: String, id: UUID = UUID(), image: UIImage, creatorPhone: String, creatorDisplayName: String, creatorRealName: String, creatorImage: UIImage) {
        self.ref = nil
        self.id = id
        self.name = leagueName
        self.leagueImage = image
        self.creatorPhone = creatorPhone
        
        self.players[creatorPhone] = (PlayerForm(phoneNumber: creatorPhone, displayName: creatorDisplayName, image: creatorImage, rank: 1, rating: GameInfo.DefaultGameInfo.DefaultRating, realName: creatorRealName))
        self.displayNameToPhoneNumber[creatorDisplayName] = creatorPhone
        self.rankPlayers()
//        self.players[creator.phoneNumber!]!.playerGames.append(Game(team1: ["+16506693169", "+16505553434"], team2: ["+16505551234", "+16505554321"], scores: ["12", "5"], gameScore: -1.5))
        //runAlgorithm()
    }
    
    init?(snapshot: DataSnapshot, id: String) {
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
        return Array(self.players.values)
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

        let p = PlayerForm(phoneNumber: phoneNumber, displayName: playerDict["displayName"] as! String, rank: 1, rating: Rating(mean: mu, standardDeviation: sigma), playerGames: [], realName: playerDict["realName"] as! String)
        
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
                var sigmaChange = 0.0
                for key in val {
                    if let keyString = key.key as? String {
                        if keyString == "gameScore" {
                            gameScore = key.value as! Double
                        }else if keyString == "sigmaChange" {
                            sigmaChange = key.value as! Double
                        }else{
                            scores.append(key.key as! String)
                            let displayNames = key.value as! [String]
                            let p1 = displayNames[0]
                            let p2 = displayNames[1]
                            teams.append([p1,p2])
                        }
                    }
                }
                player.playerGames.append(Game(team1: teams[0], team2: teams[1], scores: scores, gameScore: gameScore, sigmaChange: sigmaChange, date: each.key as! String))
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
            playerDict["realName"] = player.value.realName as AnyObject
            
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
    
    func addPlayerGame(forPlayerPhone phone: String, playerGame: Game, newRating: Rating) {
        players[phone]?.playerGames.append(playerGame)
        players[phone]?.rating = newRating
    }
    
    func deleteGame(forDate date: String, forPlayer player: PlayerForm) -> [[Game]] {
        // for each player, move their games into a dictionary. Depending on the number of players per team, there can be multiple of the same game. The dictionary will take care of this.
        var allGamesAfterDate: [Int: Game] = [:]
        for player in players.values {
            //get their initial ratings
            var mean = player.rating.Mean
            var sigma = player.rating.StandardDeviation
            while let game = player.playerGames.last, Int(game.date)! > Int(date)! {
                //bubble back each time to get back to the original game
                mean -= player.playerGames.last!.gameScore
                sigma -= player.playerGames.last!.sigmaChange
                allGamesAfterDate[Int(player.playerGames.last!.date)!] = player.playerGames.last!
                player.playerGames.removeLast()
            }
            
            if let game = player.playerGames.last, game.date == date && (game.team1.contains(player.displayName) || game.team2.contains(player.displayName)) {
                mean -= game.gameScore
                sigma -= game.sigmaChange
                player.playerGames.removeLast() // remove the actual game but dont add it to allgamesafterdate                
            }
            
            //set the player rating to whatever it was before this game
            player.rating = Rating(mean: mean, standardDeviation: sigma)
        }
        
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
        self.rankPlayers()
        return gamesToUpload
    }
}
