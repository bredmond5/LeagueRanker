//
//  UnitTestFunctions.swift
//  ScoreSenderTests
//
//  Created by Brice Redmond on 8/24/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation
import XCTest
import UIKit

class UnitTestFunctions {
    
    private static let ErrorTolerance = 0.085;


    static func login(session: FirebaseSession, withPhoneNumber phoneNumber: String, realName: String, completion: @escaping () -> ()) {
       session.logOut()
       session.login(withPhoneNumber: phoneNumber, resignRequired: { error in
           print("session.login \(phoneNumber), \(realName)")
           if let error = error {
               XCTFail("Error: \(error.localizedDescription)")
               return
           }
            session.tryVerificationCode(verificationCode: "654321", completion: { error in
               if let error = error {
                   XCTFail("Error: \(error.localizedDescription)")
                   return
               }
               XCTAssertEqual(session.session!.realName!, realName)
               XCTAssertEqual(session.session!.phoneNumber, phoneNumber)
               completion()
           })
       })
   }
    
    static func loginNoLogout(session: FirebaseSession, withPhoneNumber phoneNumber: String, realName: String, completion: @escaping () -> ()) {
        session.tryLogIn(completion: { isLoggedIn, error in
            if let error = error {
                print(error.localizedDescription)
                XCTFail("Error \(error.localizedDescription)")
                return
            }
            if !isLoggedIn || session.session!.phoneNumber != phoneNumber {
                login(session: session, withPhoneNumber: phoneNumber, realName: realName, completion: {
                    completion()
                })
                return
            } else {
                XCTAssertEqual(session.session!.realName!, realName)
                XCTAssertEqual(session.session!.phoneNumber, phoneNumber)
                completion()
            }
        })
    }
    
    static func checkLocalLeagueAgainst(localLeague: League, completion: @escaping () -> ()) {
        
        League.getLeagueFromFirebase(forLeagueID: localLeague.id.uuidString, forDisplay: false, shouldGetGames: true, callback: { leagueOnline in
            guard let leagueOnline = leagueOnline else {
                XCTFail("Failed getting league")
                return
            }
            
            self.checkLeaguesAreSame(league1: localLeague, league2: leagueOnline)
            self.checkAlgoIsSame(league: localLeague)
            self.checkAlgoIsSame(league: leagueOnline)
            completion()
        })
    }
    
    static func checkAlgoIsSame(league: League) {
        let ratings = runAlgo(onGames: league.leagueGames, forLeague: league)
        
        for player in league.players {
            self.assertRatingEqual(player.value.rating, ratings[player.key]!)
        }
    }
    
    static func checkLeaguesAreSame(league1: League, league2: League) {
        XCTAssert(league1.name == league2.name)
        XCTAssert(league1.creatorUID == league2.creatorUID)
        XCTAssertEqual(league1.leagueGames.count, league2.leagueGames.count)

        let league1Players = league1.players.values
        let league2Players = league2.players.values
        
        XCTAssert(league1Players.count == league2Players.count)
        for player in league1Players {
            self.assertRatingEqual(player.rating, league2.players[player.id]!.rating)
            XCTAssertEqual(player.playerGames.count, league2.players[player.id]!.playerGames.count)
            XCTAssertEqual(player.displayName, league2.players[player.id]!.displayName)
            XCTAssertEqual(player.realName, league2.players[player.id]!.realName)
        }
    }
    
    static func runAlgo(onGames games: [Game], forLeague league: League) -> [String: Rating] {
        var ratings: [String: Rating] = [:]
        let gameInfo = GameInfo.DefaultGameInfo
        
        for player in league.players {
            ratings[player.value.id] = gameInfo.DefaultRating
        }
        
        for game in games.reversed() {
            let newRatings = Functions.getNewRatings(players: game.team1 + game.team2, scores: game.scores, ratings: [ratings[game.team1[0]]!, ratings[game.team1[1]]!, ratings[game.team2[0]]!, ratings[game.team2[1]]!])
            ratings[game.team1[0]]! = newRatings[0]
            ratings[game.team1[1]]! = newRatings[1]
            ratings[game.team2[0]]! = newRatings[2]
            ratings[game.team2[1]]! = newRatings[3]

        }
        return ratings
    }
    
    static func assertRatingEqual(_ rating1: Rating, _ rating2: Rating) {
        XCTAssertEqual(rating1.Mean, rating2.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(rating1.StandardDeviation, rating2.StandardDeviation, accuracy: ErrorTolerance)
    }
    
    static func deleteGamesUntilEmptyFromFirstGame(session: FirebaseSession, league: League, callback: @escaping() -> ()) {
        
        if let game = league.leagueGames.first {
            fromFirstHelper(session: session, league: league, game: game, callback: {
                callback()
            })
        }
    }
    
    static func fromFirstHelper(session: FirebaseSession, league: League, game: Game, callback: @escaping() -> ()) {
        session.deleteGames(fromLeague: league, games: [game], completion: { error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
            }
            UnitTestFunctions.checkLocalLeagueAgainst(localLeague: league, completion: {
                
                if let nextGame = league.leagueGames.first {
                    XCTAssert(game > nextGame)
                    
                    self.fromFirstHelper(session: session, league: league, game: nextGame, callback: {
                        callback()
                    })
                } else {
                    callback()
                }
            })
        })
    }
    
    static func deleteGamesUntilEmptyFromLastGame(session: FirebaseSession, league: League, callback: @escaping() -> ()) {
        if let game = league.leagueGames.last {
            fromLastHelper(session: session, league: league, game: game, callback: {
                callback()
            })
        }
    }
    
    static func fromLastHelper(session: FirebaseSession, league: League, game: Game, callback: @escaping() -> ()) {
        session.deleteGames(fromLeague: league, games: [game], completion: { error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
            }
            UnitTestFunctions.checkLocalLeagueAgainst(localLeague: league, completion: {
                if let nextGame = league.leagueGames.last {
                    XCTAssert(game < nextGame)
                    self.fromLastHelper(session: session, league: league, game: nextGame, callback: {
                        callback()
                    })
                } else {
                    callback()
                }
            })
        })
    }
    
    static func deleteGamesUntilEmptyRandomGames(session: FirebaseSession, league: League, callback: @escaping() -> ()) {
        if league.leagueGames.count > 0 {
            let rand = Int.random(in: 0..<league.leagueGames.count)
            let game = league.leagueGames[rand]
            fromRandomHelper(session: session, league: league, game: game, callback: {
                callback()
            })
        }
    }
    
    static func fromRandomHelper(session: FirebaseSession, league: League, game: Game, callback: @escaping() -> ()) {
        session.deleteGames(fromLeague: league, games: [game], completion: { error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
            }
            UnitTestFunctions.checkLocalLeagueAgainst(localLeague: league, completion: {
                if league.leagueGames.count > 0 {
                    let rand = Int.random(in: 0..<league.leagueGames.count)
                    let game = league.leagueGames[rand]
                    self.fromRandomHelper(session: session, league: league, game: game, callback: {
                        callback()
                    })
                } else {
                    callback()
                }
            })
        })
    }
    
    static func getFourRandomPlayers(players: [PlayerForm]) -> [PlayerForm] {
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
    
    static func getRandomScore() -> [String] {
        var scores: Set<String> = []
        while scores.count < 2 {
            scores.insert(String(Int.random(in: 0..<100)))
        }
        return Array(scores)
    }

    
    static func addOneGame(session: FirebaseSession, players: [PlayerForm], league: League, scores: [String], fixedDate: String, completion: @escaping (Error?) -> ()) {
        session.uploadGame(curLeague: league, players: players, scores: scores, inputter: session.session!.uid, completion: { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
            
            UnitTestFunctions.checkAlgoIsSame(league: league)
        })
    }
    
    static func addMultipleGamesRandom(session: FirebaseSession, players: [PlayerForm], league: League, numGames: Int, completion: @escaping (Error?) -> ()) {
        var errorFound: Error?
        if numGames > 0 {
            self.addMultipleGamesRandom(session: session, players: players, league: league, numGames: numGames - 1, completion: { error in
                if let error = error {
                    errorFound = error
                }
                self.addOneGame(session: session, players: getFourRandomPlayers(players: players), league: league, scores: getRandomScore(), fixedDate: "\(numGames)", completion: { error in
                    if let error = error {
                        errorFound = error
                    }
                    completion(errorFound)
                })
                
            })
        } else {
            completion(nil)
        }
    }
    
    static func addMultipleGamesNotRandom(session: FirebaseSession, players: [PlayerForm], league: League, scores: [String], numGames: Int, completion: @escaping (Error?) -> ()) {
        var errorFound: Error?
        if numGames > 0 {
            self.addMultipleGamesNotRandom(session: session, players: players, league: league, scores: scores, numGames: numGames - 1, completion: { error in
                if let error = error {
                    errorFound = error
                }
                self.addOneGame(session: session, players: players, league: league, scores: scores, fixedDate: "\(numGames)", completion: { error in
                    if let error = error {
                        errorFound = error
                    }
                    completion(errorFound)
                })
                
            })
        } else {
            completion(nil)
        }
    }
    
    static func addDemoPlayers(session: FirebaseSession, toLeague league: League, amount: Int, completion: @escaping () -> ()) {
        let demoSemaphore = DispatchSemaphore(value: 1)
        let queue = DispatchQueue(label: "taskQueue")
        let group = DispatchGroup()

        for i in 0..<amount {
            group.enter()
            queue.async {
                demoSemaphore.wait()
                session.addDemoPlayer(toLeague: league, displayName: "\(i)", realName: "\(i)", image: nil, phoneNumber: "\(i)", completion: { error in
                    if let error = error {
                        XCTFail("Error: \(error.localizedDescription)")
                        return
                    }
                    group.leave()
                    demoSemaphore.signal()
                })
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
}
