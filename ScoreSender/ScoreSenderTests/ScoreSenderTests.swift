//
//  ScoreSenderTests.swift
//  ScoreSenderTests
//
//  Created by Brice Redmond on 4/7/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import XCTest

class ScoreSenderTests: XCTestCase {
    
    var creator: User?
    var league: League?
    var players: [PlayerForm] = []
    let gameInfo = GameInfo.DefaultGameInfo
    
    private let ErrorTolerance = 0.085;
    
    override func setUp() {
        creator = User(uid: "123", displayName: "Jack", phoneNumber: "6505551234", image: UIImage(), leagueNames: [])
        league = League(leagueName: "A", creator: creator!, creatorDisplayName: "Cool")
        players.append(league!.players["6505551234"]!)
        players.append(PlayerForm(phoneNumber: "6505554321", displayName: "Guy", rank: 1, rating: gameInfo.DefaultRating, playerGames: [], realName: "Ben"))
        players.append(PlayerForm(phoneNumber: "6505551111", displayName: "Pal", rank: 1, rating: gameInfo.DefaultRating, playerGames: [], realName: "Jake"))
        players.append(PlayerForm(phoneNumber: "6505555555", displayName: "Buddy", rank: 1, rating: gameInfo.DefaultRating, playerGames: [], realName: "Trevor"))
        players.append(PlayerForm(phoneNumber: "6505553434", displayName: "Dude", rank: 1, rating: gameInfo.DefaultRating, playerGames: [], realName: "Joe"))
        players.append(PlayerForm(phoneNumber: "6505554343", displayName: "Man", rank: 1, rating: gameInfo.DefaultRating, playerGames: [], realName: "Devin"))
        
        league!.players[players[1].phoneNumber] = players[1]
        league!.displayNameToPhoneNumber[players[1].displayName] = players[1].phoneNumber
        league!.players[players[2].phoneNumber] = players[2]
        league!.displayNameToPhoneNumber[players[2].displayName] = players[2].phoneNumber
        league!.players[players[3].phoneNumber] = players[3]
        league!.displayNameToPhoneNumber[players[3].displayName] = players[3].phoneNumber
        league!.players[players[4].phoneNumber] = players[4]
        league!.displayNameToPhoneNumber[players[4].displayName] = players[4].phoneNumber
        league!.players[players[5].phoneNumber] = players[5]
        league!.displayNameToPhoneNumber[players[5].displayName] = players[5].phoneNumber

    }

   func testDeleteOneGame() {
        //create a game
        let game = addOneGame(players: [players[0], players[1], players[2], players[3]], scores: ["12","4"], fixedDate: "1")
        
        //delete the game and get all the games after
        let games = league!.deleteGame(forDate: game.date, forPlayer: players[0])
        XCTAssert(games.isEmpty)
        for player in league!.players {
            XCTAssertEqual(player.value.rating.Mean, 25.00)
            XCTAssertEqual(player.value.rating.StandardDeviation, 25.0/3.0)
        }
        
//        for game in allGamesAfterDate.values {
//            for p in game.team1 + game.team2 {
//                let oldPlayerMean = players[i].rating.Mean
//                let oldPlayerSigma = players[i].rating.StandardDeviation
//                let newRating = newRatings[i]
//                let gameToAdd = Game(team1: game.team1, team2: game.team2, scores: game.scores, gameScore: newRating.Mean - oldPlayerMean, sigmaChange: newRating.StandardDeviation - oldPlayerSigma, date: game.date)
//                players[i].playerGames.append(gameToAdd)
//            }
//        }
    }
    
    func testDeleteTwoGamesFirstGameFirst() {
        let game1 = addOneGame(players: [players[0], players[1], players[2], players[3]], scores: ["12","4"], fixedDate: "1")
        sleep(UInt32(1)) // make sure that the dates are different
        let game2 = addOneGame(players: [players[0], players[1], players[2], players[3]], scores: ["12","4"], fixedDate: "2")
        
        var games = league!.deleteGame(forDate: game1.date, forPlayer: players[0])
        XCTAssertEqual(games.count, 1)
        XCTAssertEqual(games[0].count, 4)
        
        //winners
        XCTAssertEqual(28.108, league!.players[players[0].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, league!.players[players[0].phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(28.108, league!.players[players[1].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, league!.players[players[1].phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)

        //losers
        XCTAssertEqual(21.892, league!.players[players[2].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, league!.players[players[2].phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(21.892, league!.players[players[3].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, league!.players[players[3].phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)
        
        games = league!.deleteGame(forDate: game2.date, forPlayer: players[0])
        XCTAssertEqual(games.count, 0)
        
        for player in league!.players {
            XCTAssertEqual(player.value.rating.Mean, 25.00)
            XCTAssertEqual(player.value.rating.StandardDeviation, 25.0/3.0)
        }
            
        
    }
    
    func testDeleteTwoGamesSecondGameFirst() {
        let game1 = addOneGame(players: [players[0], players[1], players[2], players[3]], scores: ["12","4"], fixedDate: "1")
        let game2 = addOneGame(players: [players[0], players[1], players[2], players[3]], scores: ["12","4"], fixedDate: "2")
        
        var games = league!.deleteGame(forDate: game2.date, forPlayer: players[0])
        XCTAssertEqual(games.count, 0)
        
        //winners
        XCTAssertEqual(28.108, league!.players[players[0].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, league!.players[players[0].phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(28.108, league!.players[players[1].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, league!.players[players[1].phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)

        //losers
        XCTAssertEqual(21.892, league!.players[players[2].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, league!.players[players[2].phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(21.892, league!.players[players[3].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, league!.players[players[3].phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)
        
        games = league!.deleteGame(forDate: game1.date, forPlayer: players[0])
        XCTAssertEqual(games.count, 0)
        
        for player in league!.players {
            XCTAssertEqual(player.value.rating.Mean, 25.00)
            XCTAssertEqual(player.value.rating.StandardDeviation, 25.0/3.0)
        }
    }
    
    func testDeleteTwoGamesDifferentWinners(){
        let game1 = addOneGame(players: [players[0], players[1], players[2], players[3]], scores: ["12","4"], fixedDate: "1")
        let game2 = addOneGame(players: [players[2], players[1], players[0], players[3]], scores: ["12","4"], fixedDate: "2")
        
        var games = league!.deleteGame(forDate: game1.date, forPlayer: players[2])
        XCTAssertEqual(games.count, 1)
        
        //winners
        XCTAssertEqual(28.108, league!.players[players[2].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, league!.players[players[2].phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(28.108, league!.players[players[1].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, league!.players[players[1].phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)

        //losers
        XCTAssertEqual(21.892, league!.players[players[0].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, league!.players[players[0].phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(21.892, league!.players[players[3].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, league!.players[players[3].phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)
        
        games = league!.deleteGame(forDate: game2.date, forPlayer: players[0])
        XCTAssertEqual(games.count, 0)
       
        for player in league!.players {
            XCTAssertEqual(player.value.rating.Mean, 25.00)
            XCTAssertEqual(player.value.rating.StandardDeviation, 25.0/3.0)
        }
    }
    
    func testDeleteWithFivePlayers() {
        let game1 = addOneGame(players: [players[0], players[1], players[2], players[3]], scores: ["12","4"], fixedDate: "1")
        let game2 = addOneGame(players: [players[1], players[2], players[3], players[4]], scores: ["12","4"], fixedDate: "2")
        
        XCTAssertEqual(28.108, league!.players[players[0].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        
        var games = league!.deleteGame(forDate: game1.date, forPlayer: players[2])
        
        XCTAssertEqual(games.count, 1)
        XCTAssertEqual(25.0, league!.players[players[0].phoneNumber]!.rating.Mean)
        XCTAssertEqual(25.0/3.0, league!.players[players[0].phoneNumber]!.rating.StandardDeviation)
        
        //winners
        XCTAssertEqual(28.108, league!.players[players[1].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, league!.players[players[1].phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(28.108, league!.players[players[2].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, league!.players[players[2].phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)

        //losers
        XCTAssertEqual(21.892, league!.players[players[3].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, league!.players[players[3].phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(21.892, league!.players[players[4].phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, league!.players[players[4].phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)
        
        games = league!.deleteGame(forDate: game2.date, forPlayer: players[0])
        XCTAssertEqual(games.count, 0)
        
        for player in league!.players {
            XCTAssertEqual(player.value.rating.Mean, 25.00)
            XCTAssertEqual(player.value.rating.StandardDeviation, 25.0/3.0)
        }
        
    }
    
    func testDeleteFiftyGamesFromEnd() {
        var ratingsWinner: [Rating] = []
        var ratingsLoser: [Rating] = []
        var dates: [String] = []
        for i in 0..<50 {
            ratingsWinner.append(players[0].rating)
            ratingsLoser.append(players[2].rating)
            dates.append(addOneGame(players: [players[0], players[1], players[2], players[3]], scores: ["12","4"], fixedDate: String(i)).date)
           
        }
        
        for i in stride(from: 49, through: 0, by: -1) {
            let games = league!.deleteGame(forDate: dates[i], forPlayer: players[2])
            XCTAssertEqual(games.count, 0)

            XCTAssertEqual(ratingsWinner[i].Mean, players[0].rating.Mean)
            XCTAssertEqual(ratingsWinner[i].StandardDeviation, players[0].rating.StandardDeviation)
            
            XCTAssertEqual(ratingsLoser[i].Mean, players[2].rating.Mean)
            XCTAssertEqual(ratingsLoser[i ].StandardDeviation, players[2].rating.StandardDeviation)
        }
    }
    
    func testDeleteFiftyGamesFromBeginning() {
        var ratingsWinner: [Rating] = []
        var ratingsLoser: [Rating] = []
        var dates: [String] = []
        for i in 0..<50 {
            ratingsWinner.append(players[0].rating)
            ratingsLoser.append(players[2].rating)
            dates.append(addOneGame(players: [players[0], players[1], players[2], players[3]], scores: ["12","4"], fixedDate: String(i)).date)
           
        }
        // the idea here is that if you delete from the beginning, since its like a game at the end, it should affect the score the same.
        for i in stride(from: 0, through: 49, by: 1) {
            let games = league!.deleteGame(forDate: dates[i], forPlayer: players[2])
            XCTAssertEqual(games.count, 49 - i)
            
            XCTAssertEqual(ratingsWinner[49-i].Mean, players[0].rating.Mean)
            XCTAssertEqual(ratingsWinner[49-i].StandardDeviation, players[0].rating.StandardDeviation)
            
            XCTAssertEqual(ratingsLoser[49-i].Mean, players[2].rating.Mean)
            XCTAssertEqual(ratingsLoser[49-i].StandardDeviation, players[2].rating.StandardDeviation)
        }
    }
    
    func testDeleteRandomGames() {
        var games: [Game] = []
        for i in 0..<100 {
            games.append(addOneGame(players: getFourRandomPlayers(), scores: getRandomScore(), fixedDate: "\(i)"))
        }
        
        while games.count > 0 {
            let num = Int.random(in: 0..<games.count)
            var gamesReRun = games
            gamesReRun.remove(at: num)
            let ratings = runAlgo(onGames: gamesReRun)
            let gamesFromLeague = league!.deleteGame(forDate: games[num].date, forPlayer: league!.players[league!.displayNameToPhoneNumber[games[num].team1[0]]!]!)
            XCTAssertEqual(gamesFromLeague.count, games.count - num - 1)
            for i in 0..<players.count {
                XCTAssertEqual(players[i].rating.Mean, ratings[i].Mean, accuracy: ErrorTolerance)
                XCTAssertEqual(players[i].rating.StandardDeviation, ratings[i].StandardDeviation, accuracy: ErrorTolerance)
            }
            games.remove(at: num)
        }
        
        XCTAssertEqual(league!.players["6505554321"]!.playerGames.count, 0)
    }
    
    func testReRunAlgorithm() {
        var games: [Game] = []
        for i in 0..<100 {
            games.append(addOneGame(players: getFourRandomPlayers(), scores: getRandomScore(), fixedDate: "\(i)"))
        }
        
        var ratings: [PlayerForm: Rating] = [:]
        
        for player in league!.players.values {
            ratings[player] = player.rating
        }
        
        let newGames = league!.recalculateRankings()
        
        XCTAssertEqual(games.count, newGames.count)
        
        for i in 0..<newGames.count {
            XCTAssertEqual(newGames[i][0].date, games[i].date)
            XCTAssertEqual(newGames[i][0].scores, games[i].scores)
        }
        
        for (player, rating) in ratings {
            XCTAssertEqual(rating.Mean, league!.players[player.phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
            XCTAssertEqual(rating.StandardDeviation, league!.players[player.phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)
        }
    }
    
//    func testDeleteAnother() {
//            //create a game
//            let game = addOneGame(players: [players[0], players[1], players[2], players[3]], scores: ["12","4"], fixedDate: "1")
//            let game2 = addOneGame(players: [players[0], players[1], players[2], players[3]], scores: ["4","12"], fixedDate: "2")
//        
//        for player in league!.players.values {
//            print(player.rating.Mean)
//        }
//    }
    
    func getFourRandomPlayers() -> [PlayerForm] {
        var p: Set<Int> = []
        
        while p.count < 4 {
            let num = Int.random(in: 0..<players.count)
            p.insert(num)
        }
        
        var ps: [PlayerForm] = []
        
        for a in p {
            ps.append(players[a])
        }
        return ps
    }
    
    func getRandomScore() -> [String] {
        var scores: Set<String> = []
        while scores.count < 2 {
            scores.insert(String(Int.random(in: 0..<100)))
        }
        return Array(scores)
    }

    
    func addOneGame(players: [PlayerForm], scores: [String], fixedDate: String) -> Game {
        let (game, newRatings) = Functions.checkValidGameAndGetGameScores(players: [players[0].displayName, players[1].displayName, players[2].displayName, players[3].displayName], scores: scores, ratings: [players[0].rating, players[1].rating, players[2].rating, players[3].rating], gameDate: fixedDate)!
        
        //add the game to each player
        for i in 0..<players.count {
            let oldPlayerMean = players[i].rating.Mean
            let oldPlayerSigma = players[i].rating.StandardDeviation
            let newRating = newRatings[i]
            let gameToAdd = Game(team1: game.team1, team2: game.team2, scores: game.scores, gameScore: newRating.Mean - oldPlayerMean, sigmaChange: newRating.StandardDeviation - oldPlayerSigma, date: game.date)
            league?.addPlayerGame(forPlayerPhone: players[i].phoneNumber, playerGame: gameToAdd, newRating: newRating)
        }
        return game
    }
    
    func runAlgo(onGames games: [Game]) -> [Rating] {
        var ratings: [Rating] = []
        var key: [String: Int] = [:]
        
        for i in 0..<players.count {
            ratings.append(gameInfo.DefaultRating)
            key[players[i].displayName] = i
        }
        
        for game in games {
            let newRatings = Functions.getNewRatings(players: game.team1 + game.team2, scores: game.scores, ratings: [ratings[key[game.team1[0]]!], ratings[key[game.team1[1]]!], ratings[key[game.team2[0]]!], ratings[key[game.team2[1]]!]])
            ratings[key[game.team1[0]]!] = newRatings[0]
            ratings[key[game.team1[1]]!] = newRatings[1]
            ratings[key[game.team2[0]]!] = newRatings[2]
            ratings[key[game.team2[1]]!] = newRatings[3]

        }
        return ratings
    }
}
