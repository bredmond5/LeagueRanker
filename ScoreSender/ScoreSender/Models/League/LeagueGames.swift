//
//  LeagueGames.swift
//  ScoreSender
//
//  Created by Brice Redmond on 9/16/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import FirebaseDatabase

class LeagueGames {
    
    var ref: DatabaseReference
    var leagueGames: [Game] = []
    
    weak var leagueSettings: LeagueSettings?
    let needsSorting: (() -> ())
    
    init(ref: DatabaseReference, leagueSettings: LeagueSettings, needsSorting: @escaping () -> ()) {
        self.ref = ref
        self.leagueGames = []
        self.leagueSettings = leagueSettings
        self.needsSorting = needsSorting
        observeGames()
    }
    
    func observeGames() {
        ref.queryLimited(toFirst: 20).observe(.value) { [weak self] snapshot in
            self?.leagueGames = []
            guard let gamesDict = snapshot.value as? NSDictionary else {
                print("no games!")
                return
            }
            self?.getGames(gamesDict)
            self?.needsSorting()
        }
    }
    
    func getGames(_ gamesDict: NSDictionary) {
        
        for each in gamesDict {
            if let val = each.value as? NSDictionary {
                if let game = Game(gameDict: val, id: UUID(uuidString: each.key as! String)!) {
                    self.leagueGames.insert(game, at: 0)
                }
            }
        }
        
        leagueGames.sort(by: >)
    }
    
    deinit {
        print("league games deinit called")
        ref.removeAllObservers()
    }
    
    func getDictionary(forGame game: Game) -> [AnyHashable : Any] {
        return ["/games/\(game.id)" : game.toAnyObject()]
    }
        
        
//        self.leagueGames.insert(overallGame, at: 0)
//        leagueGames.sort(by: >)
//        for (key, value) in ratingsFromFirebase {
//            players[key]?.rating = value
//        }
//        addGame(overallGame)
//    }
    
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
    
    func removeGames(from player: PlayerForm, shouldDeletePlayerGames: Bool, shouldDeletePlayerInputGames: Bool) {
        //THIS NEEDS TO PULL ALL THE GAMES, REMOVE ALL THE ONES THAT CONTAIN THIS PLAYER
        
//        var games: [Game] = []
//        if shouldDeletePlayerGames {
//            if shouldDeletePlayerInputGames {
//                for game in league.leagueGames {
//                    if game.inputter == player.id || (game.team1 + game.team2).contains(player.id) {
//                        games.append(game)
//                    }
//                }
//            } else {
//                games = player.playerGames
//            }
//            group.enter()
//        }
//
//        if games.count > 0 {
//            group.enter()
//            deleteGames(fromLeague: league, games: player.playerGames, completion: { error in
//                if let error = error {
//                    errorFound = error
//                }
//                group.leave()
//            })
//        }
}
}
