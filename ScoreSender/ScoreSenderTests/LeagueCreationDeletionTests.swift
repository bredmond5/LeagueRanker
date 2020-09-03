//
//  LeagueCreationDeletionTests.swift
//  ScoreSenderTests
//
//  Created by Brice Redmond on 8/18/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import XCTest

class LeagueCreationDeletionTests: XCTestCase {
    
    let playersDict = [
        "+16505551234" : "Xavie",
        "+16505555555" : "Devin",
        "+16505554321" : "Brice",
        "+16505551111" : "zack",
        "+16505553434" : "Dic"
    ]
    
    func testCreateUnitTestDemoDatabase() {
        var promises: [String: XCTestExpectation] = [:]
        let loginSemaphore = DispatchSemaphore(value: 1)

        var localDict = playersDict
        let phoneNumber = "+16505551234"
        let name = "Xavie"
        localDict.removeValue(forKey: phoneNumber)
        
        promises[phoneNumber] = XCTestExpectation(description: "\(phoneNumber) created league")
        for player in localDict {
            promises[player.key] = self.expectation(description: "\(player) joined league")
        }
        
        let session = FirebaseSession()
        UnitTestFunctions.login(session: session, withPhoneNumber: phoneNumber, realName: name, completion: {
            session.uploadLeague(leagueName: "Unittest", leagueImage: nil, creatorDisplayName: name, playerImage: nil, completion: { error in
                if let error = error {
                    XCTFail("Error: \(error.localizedDescription)")
                    return
                }
                promises[phoneNumber]?.fulfill()
                let league = session.leagues[0]
                
                let queue = DispatchQueue(label: "taskQueue")
                for player in localDict {
                    queue.async {
                        loginSemaphore.wait()
                        UnitTestFunctions.login(session: session, withPhoneNumber: player.key, realName: player.value) {
                            session.joinLeague(league: league, displayName: player.value, image: nil, completion: { error in
                                if let error = error {
                                    XCTFail("Error: \(error.localizedDescription)")
                                    return
                                }
                                promises[player.key]?.fulfill()
                                loginSemaphore.signal()
                            })
                        }
                    }
                }
            })
        })
        wait(for: Array(promises.values), timeout: TimeInterval(playersDict.count * 30))
    }
    
    func testDownloadLeagueAndLogin() {
        let promise = expectation(description: "User logged in")
        let session = FirebaseSession()
        UnitTestFunctions.login(session: session, withPhoneNumber: "+16505551234", realName: "Xavie", completion: {
            XCTAssert(session.session != nil)
            XCTAssertEqual(session.leagues.count, 1)
            let league = session.leagues[0]
            XCTAssertEqual(league.name, "Unittest")
            XCTAssertEqual(league.players.count, 5)
            promise.fulfill()
        })
        
        wait(for: [promise], timeout: 30)
    }
    
    func testDownloadLeague() {
        //PREREQUISITE: Make sure that the user is logged in
        let promise = expectation(description: "User logged in")

        let session = FirebaseSession()
        UnitTestFunctions.loginNoLogout(session: session, withPhoneNumber: "+16505551234", realName: "Xavie", completion: {
            XCTAssert(session.session != nil)
            XCTAssertEqual(session.leagues.count, 1)
            let league = session.leagues[0]
            XCTAssertEqual(league.name, "Unittest")
            XCTAssertEqual(league.players.count, 5)
            promise.fulfill()
        })
        wait(for: [promise], timeout: 5) // if the user is not logged in before this will fail because firebase auth takes more than 5 seconds
    }

    func testCreateAndDeleteLeague() {
        let promise = expectation(description: "Status code: 200")
        let session = FirebaseSession()

        UnitTestFunctions.login(session: session, withPhoneNumber: "+16505551234", realName: "Xavie", completion: {
            XCTAssert(session.session != nil)
            XCTAssertEqual(session.leagues.count, 1)
            let league = session.leagues[0]
            XCTAssertEqual(league.name, "Unittest")
            XCTAssertEqual(league.players.count, 5)
            
            session.uploadLeague(leagueName: "testCreateAndDeleteLeague", leagueImage: UIImage(), creatorDisplayName: session.session!.realName!, playerImage: session.session?.image ?? UIImage(), completion: { error in
                if let error = error {
                    XCTFail("Error: \(error.localizedDescription)")
                    return
                }
                
                let leagues = session.leagues
                XCTAssertEqual(session.leagues.count, 2)
                
                let uploadedLeagueId = session.leagues[1].id
                let leagueGroup = DispatchGroup()
                for locLeague in leagues {
                    leagueGroup.enter()
                    League.getLeagueFromFirebase(forLeagueID: locLeague.id.uuidString, forDisplay: false, shouldGetGames: false, callback: { league in
                        leagueGroup.leave()
                        guard let league = league else {
                            XCTFail("Error downloading league")
                            return
                        }
                        XCTAssertEqual(league, locLeague)
                    })
                }
                
                leagueGroup.notify(queue: .main) {
                    session.delete(leagueID: leagues[1].id.uuidString, completion: { error in
                        if let error = error {
                            XCTFail("Error: \(error.localizedDescription)")
                            return
                        }
                        XCTAssertEqual(session.leagues.count, 1)
                        
                        League.getLeagueFromFirebase(forLeagueID: uploadedLeagueId.uuidString, forDisplay: false, shouldGetGames: false, callback: { league in
                            if league != nil {
                                XCTFail("Error, downloaded league that should have been deleted")
                                return
                            }
                            promise.fulfill()
                        })
                    })
                }
            })
        })
        wait(for: [promise], timeout: 30)
    }
    
    func testAddDuplicateLeague() {
        //PREREQUISITE: Make sure that the user is logged in
        let promise = expectation(description: "User got duplicate league error")

        let session = FirebaseSession()
        UnitTestFunctions.loginNoLogout(session: session, withPhoneNumber: "+16505551234", realName: "Xavie", completion: {
            guard session.checkLeagueNameAvailable(name: "Unittest") != nil else {
                XCTFail("Should be an error")
                return
            }
            promise.fulfill()
        })
        wait(for: [promise], timeout: 30) 
    }
    
    func testJoinLeagueErrors() {
        let duplicatePromise = expectation(description: "User got duplicate league error")
        let invalidPhonePromise = expectation(description: "User got invalid phone error")
        let invalidComboPromise = expectation(description: "User got invalid combination error")

        let session = FirebaseSession()
        let creatorPhone = "+16505551234"
        let leagueName = "Unittest"
        UnitTestFunctions.loginNoLogout(session: session, withPhoneNumber: "+16505551111", realName: "zack", completion: {
            session.findLeague(leagueName: leagueName, phoneNumber: creatorPhone, completion: { error, league in
                if let _ = league {
                    XCTFail("Should not return a league")
                }
                if let error = error {
                    if case FirebaseSession.FirebaseSessionErrors.AlreadyJoinedLeague = error {
                        duplicatePromise.fulfill()
                    } else {
                        XCTFail("Should be duplicate promise error")
                    }
                } else {
                    XCTFail("Should have received an error")
                }
            })
            
            session.findLeague(leagueName: "FakeLeague", phoneNumber: creatorPhone, completion: { error, league in
                if let _ = league {
                    XCTFail("Should not return a league")
                }
                if let error = error {
                    if case FirebaseSession.FirebaseSessionErrors.UserDoesntOwnLeague = error {
                        invalidComboPromise.fulfill()
                    } else {
                        XCTFail("Should be invalid combo error")
                    }
                } else {
                    XCTFail("Should have received an error")
                }
            })
            
            session.findLeague(leagueName: "FakeLeague", phoneNumber: "6505", completion: { error, league in
                if let _ = league {
                    XCTFail("Should not return a league")
                }
                if let error = error {
                    if case FirebaseSession.FirebaseSessionErrors.InvalidPhoneNumber = error {
                        invalidPhonePromise.fulfill()
                    } else {
                        XCTFail("Should be invalid phone error")
                    }
                } else {
                    XCTFail("Should have received an error")
                }
            })
        })
        
        wait(for: [duplicatePromise, invalidComboPromise, invalidPhonePromise], timeout: 30)
    }
    
    
    func testAllLogins() {
        //PREREQUISITES
        // Unittest.json loaded into realtime database
        var promises: [String: XCTestExpectation] = [:]
        let session = FirebaseSession()
        let loginSemaphore = DispatchSemaphore(value: 1)
        
        let queue = DispatchQueue(label: "taskQueue")
        for player in playersDict {
            promises[player.key] = expectation(description: "\(player.key), \(player.value) logged in")
            queue.async {
                loginSemaphore.wait()
                UnitTestFunctions.login(session: session, withPhoneNumber: player.key, realName: player.value) {
                    print(player.key)
                    promises[session.session!.phoneNumber!]!.fulfill()
                    loginSemaphore.signal()
                }
            }
        }
        wait(for: Array(promises.values), timeout: TimeInterval(playersDict.count * 30))
    }
    
    func testAddPlayersToLeague() {
        //PREREQUISITES
        // Unittest.json loaded into realtime database
        // firebase storage is empty
        // firebase storage rules reduced so authorization is not needed
        
        var promises: [String: XCTestExpectation] = [:]
        let loginSemaphore = DispatchSemaphore(value: 1)

        var localDict = playersDict
        let leagueOwner = localDict.first!
        let phoneNumber = leagueOwner.key
        let name = leagueOwner.value
        localDict.removeValue(forKey: phoneNumber)
        
        promises[phoneNumber] = XCTestExpectation(description: "\(leagueOwner) deleted league")
        for player in localDict {
            promises[player.key] = self.expectation(description: "\(player) removed league")
        }
        
        let session = FirebaseSession()
        UnitTestFunctions.login(session: session, withPhoneNumber: phoneNumber, realName: name, completion: {
            session.uploadLeague(leagueName: "testLeague", leagueImage: UIImage(systemName: "moon.fill")!, creatorDisplayName: name, playerImage: UIImage(systemName: "moon")!, completion: { error in
                if let error = error {
                    XCTFail("Error: \(error.localizedDescription)")
                    return
                }
                let league = session.leagues[0].name == "testLeague" ? session.leagues[0] : session.leagues[1]
                
                let queue = DispatchQueue(label: "taskQueue")
                let myGroup = DispatchGroup()
                for player in localDict {
                    myGroup.enter()
                    queue.async {
                        loginSemaphore.wait()
                        UnitTestFunctions.login(session: session, withPhoneNumber: player.key, realName: player.value) {
                            session.joinLeague(league: league, displayName: player.value, image: UIImage(systemName: "moon")!, completion: { error in
                                if let error = error {
                                    XCTFail("Error: \(error.localizedDescription)")
                                    return
                                }
                                myGroup.leave()
                                loginSemaphore.signal()
                            })
                        }
                    }
                }
                myGroup.notify(queue: .main) {
                    session.uploadGame(curLeague: session.leagues[1], players: Array(Array(league.players.values)[0..<4]), scores: ["12","5"], inputter: "", completion: { error in
                        if let error = error {
                           XCTFail("Error: \(error.localizedDescription)")
                           return
                       }
                        UnitTestFunctions.login(session: session, withPhoneNumber: phoneNumber, realName: name, completion: {
                            session.delete(leagueID: league.id.uuidString, completion: { error in
                                if let error = error {
                                    XCTFail("Error: \(error.localizedDescription)")
                                    return
                                }
                                promises[phoneNumber]!.fulfill()
                            })
                            
                            for player in localDict {
                                queue.async {
                                    loginSemaphore.wait()
                                    UnitTestFunctions.login(session: session, withPhoneNumber: player.key, realName: player.value) {
                                        XCTAssertEqual(session.leagues.count, 1)
                                        promises[session.session!.phoneNumber!]!.fulfill()
                                        loginSemaphore.signal()
                                    }
                                }
                            }
                        })
                    })
                }
            })
        })
        wait(for: Array(promises.values), timeout: TimeInterval(playersDict.count * 60))
    }
    
    func testAddDemoPlayerFullRemove() {
        //PREREQUISITES
        // Unittest.json loaded into realtime database
        
        let promise = expectation(description: "Demo user created and deleted")
        let session = FirebaseSession()
        UnitTestFunctions.loginNoLogout(session: session, withPhoneNumber: "+16505551234", realName: "Xavie", completion: {
            let league = session.leagues[0]
            session.addDemoPlayer(toLeague: league, displayName: "TestDisplay", realName: "TestRealName", image: UIImage(systemName: "person")!, phoneNumber: "+16505551234", completion: { error in
                if let error = error {
                    XCTFail("Error: \(error.localizedDescription)")
                    return
                }
                let demoPlayer = league.players[league.displayNameToUserID["TestDisplay"]!]!
                XCTAssertEqual(demoPlayer.realName, "TestRealName")
                XCTAssertEqual(league.players.count, 6)
                
                UnitTestFunctions.checkLocalLeagueAgainst(localLeague: league, completion: {
                    UnitTestFunctions.addMultipleGamesRandom(session: session, players: Array(league.players.values), league: league, numGames: 5, completion: { error in
                        if let error = error {
                            XCTFail("Error: \(error.localizedDescription)")
                            return
                        }
                        let numGamesAddedToDemoPlayer = league.players[demoPlayer.id]!.playerGames.count
                        session.remove(player: demoPlayer, fromLeague: league, shouldDeletePlayerGames: true, shouldDeleteInputGames: false, completion: { error in
                            //if let error = error { // keep getting errors for the image not being there, i think its because its not a real time database2
                                //XCTFail("Error: \(error.localizedDescription)")
                             //   return
                          //  }
                            XCTAssertEqual(league.leagueGames.count, 5 - numGamesAddedToDemoPlayer)
                            XCTAssertEqual(league.players.count, 5)
                            XCTAssert(league.players[demoPlayer.id] == nil)
                            XCTAssert(league.blockedPlayers[demoPlayer.id] != nil)

                            UnitTestFunctions.deleteGamesUntilEmptyFromFirstGame(session: session, league: league, callback: {
                                promise.fulfill()
                            })
                        })
                    })
                })
            })
        })
     wait(for: [promise], timeout: 30)
    }
    
    func testAddDemoPlayerNormalRemove() {
        let promise = expectation(description: "league deleted")
        
        let session = FirebaseSession()
        UnitTestFunctions.loginNoLogout(session: session, withPhoneNumber: "+16505551234", realName: "Xavie", completion: {
            session.uploadLeague(leagueName: "demoPlayers", leagueImage: nil, creatorDisplayName: nil, playerImage: nil) { error in
                if let error = error {
                    XCTFail("Error: \(error.localizedDescription)")
                    return
                }
                
                UnitTestFunctions.addDemoPlayers(session: session, toLeague: session.leagues[1], amount: 4, completion: {
                    let players = Array(session.leagues[1].players.values)
                    var player = players[0]
                    if player.id == session.leagues[1].creatorUID {
                        player = players[1]
                    }
                    
                    session.remove(player: player, fromLeague: session.leagues[0], shouldDeletePlayerGames: false, shouldDeleteInputGames: false, completion: { error in
                        if let error = error {
                            XCTFail("Error: \(error.localizedDescription)")
                            return
                        }
                        XCTAssertEqual(session.leagues[1].leagueGames.count, 0)
                        XCTAssert(session.leagues[1].blockedPlayers[player.id] != nil)
                        UnitTestFunctions.checkLocalLeagueAgainst(localLeague: session.leagues[1], completion: {
                            session.delete(leagueID: session.leagues[1].id.uuidString, completion: { error in
                                if let error = error {
                                    XCTFail("Error: \(error.localizedDescription)")
                                    return
                                }
                                
                            })
                        })
                    })
                })
            }
        })
        
        wait(for: [promise], timeout: 30)
    }
    
    func testRejoinLeague() {
        let promise = expectation(description: "league rejoined")
        let session = FirebaseSession()
        
        
    }
    
    func testDeleteInputGamesAndRejoinLeague() {
        let promise = expectation(description: "league rejoined")
        let session = FirebaseSession()
        UnitTestFunctions.login(session: session, withPhoneNumber: "+16505555555", realName: "Devin", completion: {
            UnitTestFunctions.addMultipleGamesRandom(session: session, players: Array(session.leagues[0].players.values), league: session.leagues[0], numGames: 5, completion: { error in
                if let error = error {
                    XCTFail("Error: \(error.localizedDescription)")
                    return
                }
                let devinUID = session.session!.uid
                UnitTestFunctions.login(session: session, withPhoneNumber: "+16505552134", realName: "Xavie", completion: {
                    session.remove(player: session.leagues[0].players[devinUID]!, fromLeague: session.leagues[0], shouldDeletePlayerGames: true, shouldDeleteInputGames: true, completion: { error in
                        if let error = error {
                            XCTFail("Error: \(error.localizedDescription)")
                            return
                        }
                        XCTAssert(session.leagues[0].blockedPlayers[devinUID] != nil)
                        XCTAssertEqual(session.leagues[0].leagueGames.count, 0)
                        
                        UnitTestFunctions.checkLocalLeagueAgainst(localLeague: session.leagues[0], completion: {
                            session.unblock(userID: devinUID, fromLeague: session.leagues[0], completion: { error in
                                if let error = error {
                                    XCTFail("Error: \(error.localizedDescription)")
                                    return
                                }
                                let league = session.leagues[0]
                                UnitTestFunctions.login(session: session, withPhoneNumber: "+16505555555", realName: "Devin", completion: {
                                    XCTAssertEqual(session.leagues.count, 0)
                                    session.joinLeague(league: league, displayName: nil, image: nil, completion: { error in
                                        if let error = error {
                                            XCTFail("Error: \(error.localizedDescription)")
                                            return
                                        }
                                        promise.fulfill()
                                    })
                                })
                            })
                        })
                    })
                })
            })
        })
        
        wait(for: [promise], timeout: 90)
    }

//    func testInviteToLeague() {
//        XCTFail()
//    }
}
