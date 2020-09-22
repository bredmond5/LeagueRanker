////
////  ScoreSenderTests.swift
////  ScoreSenderTests
////
////  Created by Brice Redmond on 4/7/20.
////  Copyright © 2020 Brice Redmond. All rights reserved.
////
//
//import XCTest
//
//class DeleteGameTests: XCTestCase {
//    var league: League?
//    var players: [PlayerForm] = []
//    let gameInfo = GameInfo.DefaultGameInfo
//    
//    func asyncSetUp(completion: @escaping (Error?, FirebaseSession) -> ()) {
//        let session = FirebaseSession()
//        session.tryLogIn(completion: { isLoggedIn, error in
//            if let error = error {
//                XCTFail("Error: \(error.localizedDescription)")
//               return
//           }
//            if isLoggedIn {
//                self.league = session.leagues[0]
//                for player in self.league!.players {
//                    self.players.append(player.value)
//                }
//                completion(error, session)
//                return
//            }
//            UnitTestFunctions.login(session: session, withPhoneNumber: "6505551234", realName: "Xavie", completion: {
//                self.league = session.leagues[0]
//                for player in self.league!.players {
//                    self.players.append(player.value)
//                }
//                completion(nil, session)
//            })
//            
//        })
//        
//    }
//    
//    func sendToFirebase(numGames: Int, isRandom: Bool, completion: @escaping (FirebaseSession) -> ()) {
//        asyncSetUp(completion: { error, session in
//            if let error = error {
//                XCTFail("Error: \(error.localizedDescription)")
//                return
//            }
//            
//            if isRandom {
//                UnitTestFunctions.addMultipleGamesRandom(session: session, players: self.players, league: self.league!, numGames: numGames, completion: { error in
//                    if let error = error {
//                       XCTFail("Error: \(error.localizedDescription)")
//                       return
//                    }
//                    XCTAssertEqual(self.league!.leagueGames.count, numGames)
//                    let ratings = UnitTestFunctions.runAlgo(onGames: self.league!.leagueGames, forLeague: self.league!)
//            
//                    for player in self.league!.players {
//                        UnitTestFunctions.assertRatingEqual(player.value.rating, ratings[player.key]!)
//                    }
//                    
//                    completion(session)
//                })
//            } else {
//                UnitTestFunctions.addMultipleGamesNotRandom(session: session, players: [self.players[0], self.players[1], self.players[2], self.players[3]], league: self.league!, scores: [12,4], numGames: numGames, completion: { error in
//                    if let error = error {
//                        XCTFail("Error: \(error.localizedDescription)")
//                        return
//                    }
//                    XCTAssertEqual(self.players[0].playerGames.count, numGames)
//                    XCTAssertEqual(self.league!.leagueGames.count, numGames)
//                    completion(session)
//                })
//            }
//        })
//    }
//
//   func testDeleteOneGame() {
//    //create a game
//        let promise = expectation(description: "Status code: 200")
//    
//        sendToFirebase(numGames: 1, isRandom: false, completion: { session in
//            UnitTestFunctions.deleteGamesUntilEmptyFromFirstGame(session: session, league: self.league!, callback: {
//                promise.fulfill()
//            })
//        })
//                
//        wait(for: [promise], timeout: 5)
//    }
//    
//    func testDeleteTwoGamesFirstGameFirst() {
//        let promise = expectation(description: "Status code: 200")
//        
//        sendToFirebase(numGames: 2, isRandom: false, completion: { session in
//            UnitTestFunctions.deleteGamesUntilEmptyFromFirstGame(session: session, league: self.league!, callback: {
//                promise.fulfill()
//            })
//        })
//
//        wait(for: [promise], timeout: 5)
//
//    }
//    
//    func testDeleteTwoGamesSecondGameFirst() {
//        let promise = expectation(description: "Status code: 200")
//        
//        sendToFirebase(numGames: 2, isRandom: false, completion: { session in
//            UnitTestFunctions.deleteGamesUntilEmptyFromLastGame(session: session, league: self.league!, callback: {
//                promise.fulfill()
//            })
//        })
//
//        wait(for: [promise], timeout: 5)
//    }
//
//    func testDeleteTwoGamesDifferentWinners() {
//        let promise = expectation(description: "Status code: 200")
//        sendToFirebase(numGames: 2, isRandom: true, completion: { session in
//            UnitTestFunctions.deleteGamesUntilEmptyRandomGames(session: session, league: self.league!, callback: {
//                promise.fulfill()
//            })
//        })
//        wait(for: [promise], timeout: 5)
//    }
//
//    func testDeleteWithFiveGames() {
//        let promise = expectation(description: "Status code: 200")
//        sendToFirebase(numGames: 5, isRandom: true, completion: { session in
//            UnitTestFunctions.deleteGamesUntilEmptyFromLastGame(session: session, league: self.league!, callback: {
//                promise.fulfill()
//            })
//        })
//        wait(for: [promise], timeout: 40)
//    }
//
//    func testDeleteTenGamesFromEnd() {
//        let promise = expectation(description: "Status code: 200")
//        sendToFirebase(numGames: 10, isRandom: false, completion: { session in
//            UnitTestFunctions.deleteGamesUntilEmptyFromLastGame(session: session, league: self.league!, callback: {
//                promise.fulfill()
//            })
//        })
//        wait(for: [promise], timeout: 50)
//    }
//    
//    func testQueryLimitToFirst5() {
//        let promise = expectation(description: "Status code: 200")
//        sendToFirebase(numGames: 10, isRandom: true, completion: { session in
//            let oldLeague = session.leagues[0]
//            League.getLeagueFromFirebase(forLeagueID: oldLeague.id.uuidString, forDisplay: false, shouldGetGames: false, callback: { league in
//                XCTAssertEqual(league!.leagueGames.count, 5)
////                for i in 0..<league!.leagueGames.count {
////                    XCTAssert(league!.leagueGames[i] < oldLeague.leagueGames[i+5])
////                }
//                promise.fulfill()
//            })
//        })
//        
//        wait(for: [promise], timeout: 20)
//    }
//    
//    
//    func testDeleteTenGamesFromBeginning() {
//        let promise = expectation(description: "Status code: 200")
//           sendToFirebase(numGames: 10, isRandom: true, completion: { session in
//               UnitTestFunctions.deleteGamesUntilEmptyFromFirstGame(session: session, league: self.league!, callback: {
//                   promise.fulfill()
//               })
//           })
//           wait(for: [promise], timeout: 50)
//    }
//
//    func testDeleteTenRandomGames() {
//        let promise = expectation(description: "Status code: 200")
//        sendToFirebase(numGames: 10, isRandom: true, completion: { session in
//            UnitTestFunctions.deleteGamesUntilEmptyRandomGames(session: session, league: self.league!, callback: {
//                promise.fulfill()
//            })
//        })
//        wait(for: [promise], timeout: 50)
//    }
//    
//    func testTwoSynchronousGameInsertions() {
//        let promise = expectation(description: "Status code: 200")
//        let addGameGroup = DispatchGroup()
//        addGameGroup.enter()
//        var localSession = FirebaseSession()
//        sendToFirebase(numGames: 1, isRandom: true, completion: {
//            session in
//            addGameGroup.leave()
//            localSession = session
//        })
//        
//        addGameGroup.enter()
//        sendToFirebase(numGames: 1, isRandom: true, completion: {
//            session in
//            addGameGroup.leave()
//        })
//        
//        addGameGroup.notify(queue: .main) {
//            // race conditions on our own league, pull the online one to actually see
//            League.getLeagueFromFirebase(forLeagueID: self.league!.id.uuidString, forDisplay: false, shouldGetGames: true, callback: { leagueOnline in
//                guard let leagueOnline = leagueOnline else {
//                    XCTFail("couldnt get league")
//                    return
//                }
//                XCTAssertEqual(leagueOnline.leagueGames.count, 2)
//                UnitTestFunctions.deleteGamesUntilEmptyRandomGames(session: localSession, league: self.league!, callback: {
//                    promise.fulfill()
//                })
//            })
//        }
//        wait(for: [promise], timeout: 10)
//    }
//    
//    func TenSynchronousGameInsertions() {
//        // this one is questionable there is a lot of race conditions happening on the league
//        let promise = expectation(description: "Status code: 200")
//        let numGames = 10
//        let addGameGroup = DispatchGroup()
//        var localSession = FirebaseSession()
//        for _ in 0..<numGames {
//            addGameGroup.enter()
//            sendToFirebase(numGames: 1, isRandom: true, completion: {
//                session in
//                addGameGroup.leave()
//                localSession = session
//            })
//        }
//        
//        addGameGroup.notify(queue: .main) {
//            // race conditions on our own league, pull the online one to actually see
//            League.getLeagueFromFirebase(forLeagueID: self.league!.id.uuidString, forDisplay: false, shouldGetGames: true, callback: { leagueOnline in
//                guard let leagueOnline = leagueOnline else {
//                    XCTFail("couldnt get league")
//                    return
//                }
//                XCTAssertEqual(leagueOnline.leagueGames.count, numGames)
//                UnitTestFunctions.deleteGamesUntilEmptyRandomGames(session: localSession, league: self.league!, callback: {
//                    promise.fulfill()
//                })
//            })
//        }
//        wait(for: [promise], timeout: 15)
//    }
//
//// not even sure if this is needed
////    func testReRunAlgorithm() {
////        sendToFirebase(numGames: 10, isRandom: true, completion: { session in
////            let games = self.league!.leagueGames
////
////            var ratings: [PlayerForm: Rating] = [:]
////
////            for player in self.league!.players.values {
////                ratings[player] = player.rating
////            }
////
////            let newGames = self.league!.recalculateRankings(callback)
////
////            XCTAssertEqual(games.count, newGames.count)
////
////            for i in 0..<newGames.count {
////                XCTAssertEqual(newGames[i][0].date, games[i].date)
////                XCTAssertEqual(newGames[i][0].scores, games[i].scores)
////            }
////
////            for (player, rating) in ratings {
////                XCTAssertEqual(rating.Mean, league!.players[player.phoneNumber]!.rating.Mean, accuracy: ErrorTolerance)
////                XCTAssertEqual(rating.StandardDeviation, league!.players[player.phoneNumber]!.rating.StandardDeviation, accuracy: ErrorTolerance)
////            }
////        })
////    }
//}
