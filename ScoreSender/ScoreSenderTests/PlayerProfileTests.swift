//
//  PlayerProfileTests.swift
//  ScoreSenderTests
//
//  Created by Brice Redmond on 8/21/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import XCTest

class PlayerProfileTests: XCTestCase {
    
    func testUploadPlayerImage() {
        let promise = expectation(description: "Image changed")
        let session = FirebaseSession()
        UnitTestFunctions.loginNoLogout(session: session, withPhoneNumber: "+16505551234", realName: "Xavie", completion: {
            session.changePlayer(inLeague: session.leagues[0], newDisplayName: nil, newImage: UIImage(systemName: "person")!, forPlayer: session.leagues[0].players[session.session!.uid]!, completion: { error in
                if let error = error {
                    XCTFail("Error: \(error.localizedDescription)")
                }
                promise.fulfill()
            })
        })
        
        wait(for: [promise], timeout: 30)
    }

    func testChangeProfileInLeague() {
        let promise = expectation(description: "Display name changed back")
        let newDisplayName = "TestDic"
        let oldDisplayName = "Dic"
        let session = FirebaseSession()
        UnitTestFunctions.loginNoLogout(session: session, withPhoneNumber: "+16505553434", realName: oldDisplayName, completion: {
            session.changePlayer(inLeague: session.leagues[0], newDisplayName: newDisplayName, newImage: UIImage(systemName: "person")!, forPlayer: session.leagues[0].players[session.session!.uid]!, completion: { error in
                if let error = error {
                    XCTFail("Error: \(error.localizedDescription)")
                    return
                }
                UnitTestFunctions.checkLocalLeagueAgainst(localLeague: session.leagues[0], completion: {
                    promise.fulfill()
                })
            })
        })
        
        wait(for: [promise], timeout: 30)
    }
    
    func testSynchonousDisplayNameChanges() {
        let promise1 = expectation(description: "User 1 changed back name")
        let promise2 = expectation(description: "User 2 changed back name")
        let session1 = FirebaseSession()
        let session2 = FirebaseSession()
        
        let myGroup = DispatchGroup()
        
        let firstName = "Xavie"
        let secondName = "Brice"
        
        UnitTestFunctions.login(session: session1, withPhoneNumber: "+16505551234", realName: firstName, completion: {
             UnitTestFunctions.login(session: session2, withPhoneNumber: "+16505554321", realName: secondName, completion: {
                myGroup.enter()
                session1.changePlayer(inLeague: session1.leagues[0], newDisplayName: "Test", newImage: nil, forPlayer: session1.leagues[0].players[session1.session!.uid]!, completion: { error in
    //                if let error = error {
    //                    XCTFail("Error: \(error.localizedDescription)")
    //                    return
    //                }
                    myGroup.leave()
                })
                
                myGroup.enter()
                session2.changePlayer(inLeague: session2.leagues[0], newDisplayName: "Test", newImage: nil, forPlayer: session2.leagues[0].players[session2.session!.uid]!, completion: { error in
    //                if let error = error {
    //                    XCTFail("Error: \(error.localizedDescription)")
    //                    return
    //                }
                    myGroup.leave()
                })
                
                myGroup.notify(queue: .main) {
                   XCTAssert(session1.leagues[0].players[session1.session!.uid]!.displayName != session2.leagues[0].players[session2.session!.uid]!.displayName)
                    session1.changePlayer(inLeague: session1.leagues[0], newDisplayName: firstName, newImage: nil, forPlayer: session1.leagues[0].players[session1.session!.uid]!, completion: { error in
                       if let error = error {
                           XCTFail("Error: \(error.localizedDescription)")
                           return
                       }
                       promise1.fulfill()
                    })
                    session2.changePlayer(inLeague: session2.leagues[0], newDisplayName: secondName, newImage: nil, forPlayer: session2.leagues[0].players[session2.session!.uid]!, completion: { error in
                       if let error = error {
                           XCTFail("Error: \(error.localizedDescription)")
                           return
                       }
                       promise2.fulfill()
                   })
               }
            })
        })
        wait(for: [promise1, promise2], timeout: 60)
    }
    
    func testChangeRealName() {
        let promise = expectation(description: "Player changed realName")
        let session = FirebaseSession()
        UnitTestFunctions.loginNoLogout(session: session, withPhoneNumber: "+16505553434", realName: "Dic", completion: {
            session.changeUser(realName: "Jack") { error in
                if let error = error {
                    XCTFail("Error: \(error.localizedDescription)")
                }
                XCTAssertEqual(session.session!.realName, "Jack")
                League.getLeagueFromFirebase(forLeagueID: session.leagues[0].id.uuidString, forDisplay: false, shouldGetGames: false, callback: { league in
                    guard let league = league else {
                        XCTFail("Error downloading league")
                        return
                    }
                    XCTAssertEqual(league.players[session.session!.uid]?.realName, session.session!.realName)
                    session.changeUser(realName: "Dic", completion: { error in
                        if let error = error {
                            XCTFail("Error: \(error.localizedDescription)")
                        }
                        XCTAssertEqual(session.session!.realName, "Dic")
                        promise.fulfill()
                    })
                })
            }
        })
        wait(for: [promise], timeout: 20)
    }
    
//    func testForceUpdate() {
//        XCTFail()
//    }

    func testLeaveAndJoinLeague() {
        let promise = expectation(description: "Left and joined league")
        let session = FirebaseSession()
        UnitTestFunctions.loginNoLogout(session: session, withPhoneNumber: "+16505555555", realName: "Devin", completion: {
            let league = session.leagues[0]
            session.leaveLeague(fromLeague: session.leagues[0], completion: { error in
                if let error = error {
                    XCTFail("Error: \(error.localizedDescription)")
                    return
                }
                XCTAssertEqual(session.leagues.count, 0)
                session.rejoinLeague(league: league, completion: { error in
                    if let error = error {
                        XCTFail("Error: \(error.localizedDescription)")
                        return
                    }
                    UnitTestFunctions.checkLocalLeagueAgainst(localLeague: session.leagues[0], completion: {
                        promise.fulfill()
                    })
                })
            })
        })
        
        wait(for: [promise], timeout: 30)
    }
}
