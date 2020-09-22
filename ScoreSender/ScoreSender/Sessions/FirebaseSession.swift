//
//  FirebaseSession.swift
//
//
//  Created by Brice Redmond on 4/11/20.
//  Credit to Sebastian Esser

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import CoreData

class FirebaseSession: ObservableObject {
    
//    func saveContext() {
//      let context = container.viewContext
//      if context.hasChanges {
//        do {
//          try context.save()
//        } catch {
//          let nserror = error as NSError
//          fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
//      } else {
//        print("no changes")
//      }
//    }
    
    public enum FirebaseSessionErrors: LocalizedError {
        case LeagueDownloadError
        case PlayerScoreDownloadError
        case UploadGameError
        case ProfileDownloadError
        case DisplayNameTaken(name: String)
        case BlankDisplayName
        case DisplayNameTooLong
        case ImageUploadError
        case InvalidPhoneNumber(phoneNumber: String)
        case UserDoesntOwnLeague(leagueName: String, phoneNumber: String)
        case ErrorGettingUser
        case AlreadyJoinedLeague(leagueName: String, phoneNumber: String)
        case LeagueNameNotAvailable(leagueName: String)
        case UserOwnsLeague(leagueName: String)
        case GamesInputButNotPlayed
        case RejoinTriedIncorrectly
        case InvalidDisplayName(inLeagueName: String, displayName: String)
        case DuplicateNamesInputForGame
        case IntegersRequired
    }
    
    //MARK: Properties
    @Published var session: User?
    @Published var isLoggedIn: Bool?
    
    @Published var leagues: [League] = []

    var userRef: DatabaseReference = Database.database().reference()
    
    var storageRef = Storage.storage().reference()
    
    //MARK: PUBLIC FUNCTIONS
        
    public func tryLogIn(completion: @escaping (Bool, Error?) -> ()) {
        // This gets called when the app is opened, if the auth.auth.current user is nil then it will go to a log in screen
        // where login is called.
        
        
        let user = Auth.auth().currentUser;

        if let user = user {
            logUserIn(user, completion: { error in
                completion(true, error)
            })
        } else {
            self.isLoggedIn = false
            self.session = nil
            self.leagues = []
            completion(false, nil)
        }
    }
    
    public func login(withPhoneNumber finalPhone: String, resignRequired: @escaping (Error?) -> ()) {
        // Function called by LoginView.swift
        PhoneAuthProvider.provider().verifyPhoneNumber(finalPhone, uiDelegate: nil) { (verificationID, error) in
              if let error = error {
                resignRequired(error)
                print(error.localizedDescription)
                return
              }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            
            resignRequired(nil)
        }
        
    }
    
    func tryVerificationCode(verificationCode: String, completion: @escaping (Error?) -> ()) {
        // Function called by LoginView.swift
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let isMFAEnabled = true
                    
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
        verificationCode: verificationCode)
                    
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
          if let error = error {
            let authError = error as NSError
            if (isMFAEnabled && authError.code == AuthErrorCode.secondFactorRequired.rawValue) {
              // The user is a multi-factor user. Second factor challenge is required.
              let resolver = authError.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
              var displayNameString = ""
              for tmpFactorInfo in (resolver.hints) {
                displayNameString += tmpFactorInfo.displayName ?? ""
                displayNameString += " "
              }
                MyAlerts().showTextInputPrompt(placeholder: "", title: "Select factor to sign in\n\(displayNameString)", message: "", keyboardType: .numberPad, callback: { userPressedOk, displayName in
                    
                var selectedHint: PhoneMultiFactorInfo?
                for tmpFactorInfo in resolver.hints {
                  if (displayName == tmpFactorInfo.displayName) {
                    selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                  }
                }
                PhoneAuthProvider.provider().verifyPhoneNumber(with: selectedHint!, uiDelegate: nil, multiFactorSession: resolver.session) { verificationID, error in
                  if let error = error {
//                    self.myAlerts.showMessagePrompt(title: "Error", message: error.localizedDescription, callback: {})
                    completion(error)
                  } else {
                    MyAlerts().showTextInputPrompt(placeholder: "", title: "Verification code for \(selectedHint?.displayName ?? "")", message: "", keyboardType: .numberPad, callback: { userPressedOK, verificationCode in
                      let credential: PhoneAuthCredential? = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: verificationCode)
                      let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator.assertion(with: credential!)
                      resolver.resolveSignIn(with: assertion!) { authResult, error in
                        if let error = error {
                          //self.myAlerts.showMessagePrompt(title: "Error", message: error.localizedDescription, callback: {})
                            completion(error)
                        } else {
//                          callingView.navigationController?.popViewController(animated: true)
                        }
                      }
                    })
                  }
                }
              })
            } else {
                //self.myAlerts.showMessagePrompt(title: "Error", message: error.localizedDescription, callback: {})
                completion(error)
                return
            }
            // ...
            
            return
          }
            //everythings good, log user in
            
            if let user = authResult?.user {
                self?.logUserIn(user, completion: { [ weak self] error in
                    guard let self = self else {
                        return
                    }
                    
                    if let error = error {
                        completion(error)
                        return
                    }
                    let myGroup = DispatchGroup()

                    var errorFound: Error?
                    
                    myGroup.enter()
                    self.userRef.child("phoneNumber").setValue(self.session!.phoneNumber!) { error, ref in
                        errorFound = error
                        myGroup.leave()
                    }
                    myGroup.enter()
                    self.userRef.child("realName").setValue(self.session!.realName!) { error, ref in
                        errorFound = error
                        myGroup.leave()
                    }
                    myGroup.enter()
                    Database.database().reference(withPath: "/phoneNumberToUID/\(self.session!.phoneNumber!)").setValue(self.session!.uid) { error, ref in
                        errorFound = error
                        myGroup.leave()
                    }
                    
                    myGroup.notify(queue: .main) {
                        completion(errorFound)
                    }
                })
            } else {
                completion(FirebaseSessionErrors.ProfileDownloadError)
            }
        }
    }
    
    public func logOut() {
         try! Auth.auth().signOut()
        
        for league in leagues {
            league.removeAllObservers()
        }
        
        deleteAllData("LocalImage")
        
         self.isLoggedIn = false
         self.session = nil
         self.leagues = []
        // need to remove all observers from everything
        // need to remove
        self.userRef.child("joinedLeagues").removeAllObservers()
        self.userRef.child("ownedLeagues").removeAllObservers()
        
     }
    
    private func deleteAllData(_ entity:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        let context = SceneDelegate.persistentContainer.viewContext
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                  guard let objectData = object as? NSManagedObject else {continue}
                context.delete(objectData)
              }
            SceneDelegate.saveContext(context: context)
          } catch let error {
              print("Delete all data in \(entity) error :", error)
          }
    }
    
    public func changeUser(realName: String? = nil, image: UIImage? = nil, completion: ((Error?) -> Void)? = nil) {
        let myGroup = DispatchGroup()
        
        if let realName = realName {
            //Need to go through every league and change the display name, image, and player games
            myGroup.enter()
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = realName
            changeRequest?.commitChanges { [weak self] (error) in
                if let error = error {
                    MyAlerts().showMessagePrompt(title: "Error", message: error.localizedDescription, callback: {})
                    return
                } else {
                    self?.session!.realName = realName
                    
                    myGroup.enter()
                    self?.userRef.child("realName").setValue(realName) { error, ref in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        myGroup.leave()

                    }
                    
                    if let self = self {
                        for league in self.leagues {
                            myGroup.enter()
                            league.changeRealName(forUID: self.session!.uid, newName: realName, completion: { error in
                                if let error = error {
                                    print(error.localizedDescription)
                                }
                                myGroup.leave()
                            })
                        }
                        myGroup.leave()
                    }
                }
            }
        }
        
        if let image = image {
            session?.change(image: image)
        }
        myGroup.notify(queue: .main) {
            completion?(nil)
        }
        
    }
    
    private func newCheckDisplayName(forLeague league: League?, newDisplayName: String?) -> Error? {
        
        guard let newDisplayName = newDisplayName, newDisplayName != "" else {
            return FirebaseSessionErrors.BlankDisplayName
        }
            
        if newDisplayName.count > Constants.maxCharacterDisplayName {
            return FirebaseSessionErrors.DisplayNameTooLong
        }
        
        guard let league = league else {
            return nil
        }
        
        if league.player(atDisplayName: newDisplayName) != nil {
            return FirebaseSessionErrors.DisplayNameTaken(name: newDisplayName)
        }
        
        return nil
    }
    
    public func uploadLeague(leagueName: String, leagueImage: UIImage?, creatorDisplayName: String?, playerImage: UIImage?, completion: @escaping (Error?) -> ()) {
        if let error = newCheckDisplayName(forLeague: nil, newDisplayName: creatorDisplayName) {
            completion(error)
            return
        }
    
        League.writeLeague(leagueName: leagueName, image: leagueImage ?? Constants.defaultLeaguePhoto, creator: self.session!, creatorDisplayName: creatorDisplayName!, creatorImage: playerImage ?? Constants.defaultPlayerPhoto, numPlacements: 15, playersPerTeam: 2, completion: { id in
            self.userRef.child("ownedLeagues/\(id)").setValue("\(leagueName)") { error, ref in
                completion(error)
              }
        })
    }
    
    public func findLeague(leagueName: String, phoneNumber: String, completion: @escaping (Error?, String?, Bool) -> ()) {
        let phoneNumberToUIDRef = Database.database().reference(withPath: "phoneNumberToUID/\(phoneNumber)")
        phoneNumberToUIDRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                completion(FirebaseSessionErrors.InvalidPhoneNumber(phoneNumber: phoneNumber), nil, false)
                return
            }

            guard let userID = snapshot.value as? String else {
                completion(FirebaseSessionErrors.ErrorGettingUser, nil, false)
                return
            }

            let creatorRef = Database.database().reference(withPath: "users/\(userID)/ownedLeagues")
            creatorRef.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                if !snapshot.exists() {
                    completion(FirebaseSessionErrors.InvalidPhoneNumber(phoneNumber: phoneNumber), nil, false)
                    return
                }else{
                    let optional = snapshot.value as? NSDictionary
                    guard let value = optional else {
                        completion(FirebaseSessionErrors.ErrorGettingUser, nil, false)
                        return
                    }
                    var foundLeague = false
                    for each in value {
                        if let localName = each.value as? String {
                            if localName == leagueName {
                                foundLeague = true
                                
                                guard let leagueID = each.key as? String else {
                                    completion(FirebaseSessionErrors.LeagueDownloadError, nil, false)
                                    return
                                }
                                
                                Database.database().reference(withPath: "leagues/\(leagueID)/players/playerIDs").observeSingleEvent(of: .value) { snapshot in
                                    guard let value = snapshot.value as? NSDictionary else {
                                        completion(FirebaseSessionErrors.LeagueDownloadError, nil, false)
                                        return
                                    }
                                    
                                    if let val = value[self?.session!.uid ?? ""] as? Bool {
                                        if val == true {
                                            completion(FirebaseSessionErrors.AlreadyJoinedLeague(leagueName: leagueName, phoneNumber: phoneNumber), nil, true)
                                            return
                                        } else {
                                            completion(nil, leagueID, false)
                                        }
                                    }
                                    completion(nil, leagueID, false)
                                }
                            }
                        }
                    }
                    if !foundLeague {
                        completion(FirebaseSessionErrors.UserDoesntOwnLeague(leagueName: leagueName, phoneNumber: phoneNumber), nil, false)
                        return
                    }
                }
            })
        })
    }
    
    public func checkLeagueNameAvailable(name: String) -> Error? {
        for league in leagues {
            if league.name == name {
                if league.ownsLeague(userID: self.session!.uid) {
                    return FirebaseSessionErrors.LeagueNameNotAvailable(leagueName: name)
                }
            }
        }
        return nil
    }
    
    public func joinLeague(leagueID: String, displayName: String?, image: UIImage?, completion: ((Error?) -> Void)? = nil)
    {
        guard let session = self.session else {
             completion?(FirebaseSessionErrors.ErrorGettingUser)
             return
         }
        // Called by JoinLeague.swift. Add the current user to the league
        checkNewPlayer(displayName: displayName, leagueID: leagueID, completion: { error in
            if let error = error {
                completion?(error)
                return
            }
            League.newPlayerDict(leagueID, playerID: session.uid, session.realName!, session.phoneNumber!, displayName!, image ?? Constants.defaultPlayerPhoto, completion: { playerDict in
                    
                var write = [String: Any]()
                let playersPath = "leagues/\(leagueID)/players"
                
                write["\(playersPath)/objects/\(session.uid)"] = playerDict
                write["\(playersPath)/displayNames/\(displayName!)"] = true
                write["\(playersPath)/playerIDs/\(session.uid)"] = true
                
                write["users/\(session.uid)/joinedLeagues/\(leagueID)"] = true
            
                Database.database().reference().updateChildValues(write) { error, ref in
                    completion?(error)
                }
            })
        })
    }
    
    public func checkNewPlayer(displayName: String?, leagueID: String, completion: @escaping (Error?) -> ()) {
         
         guard let displayName = displayName else {
            completion(FirebaseSessionErrors.BlankDisplayName)
            return
         }
        
         if displayName == "" {
             completion(FirebaseSessionErrors.BlankDisplayName)
             return
         }
            
         if displayName.count > Constants.maxCharacterDisplayName {
             completion(FirebaseSessionErrors.DisplayNameTooLong)
             return
         }
         
         Database.database().reference(withPath: "leagues/\(leagueID)/players/displayNames").observeSingleEvent(of: .value, with: { snapshot in
             guard let names = snapshot.value as? NSDictionary else {
                 completion(FirebaseSessionErrors.LeagueDownloadError)
                 return
             }
             
             if names[displayName] != nil {
                 completion(FirebaseSessionErrors.DisplayNameTaken(name: displayName))
                 return
             }
            
            completion(nil)
        })
    }
    
    public func rejoinLeague(leagueID: String, completion: @escaping (Error?) -> ()) {
        guard let session = self.session else {
            completion(FirebaseSessionErrors.ErrorGettingUser)
            return
        }
        
        var writeObject = [String: Any]()
        writeObject["users/\(session.uid)/joinedLeagues/\(leagueID)"] = true
        writeObject["leagues/\(leagueID)/players/objects/\(session.uid)/values/realName"] = session.realName
        
        Database.database().reference().updateChildValues(writeObject, withCompletionBlock: { error, ref in
            completion(error)
        })
    }
    
    public func uploadGame(curLeague: League, players: [String], scores: [String], inputter: String, completion: @escaping (Error?) -> ()) {

        var uids: [String] = []
        for player in players {
            if player == "" {
                completion(FirebaseSessionErrors.BlankDisplayName)
                return
            }
            
            if let p = curLeague.player(atDisplayName: player) {
                uids.append(p.id)
            } else {
                completion(FirebaseSessionErrors.InvalidDisplayName(inLeagueName: curLeague.name, displayName: player))
                return
            }
        }
        
        if !scores[0].isInt || !scores[1].isInt {
            completion(FirebaseSessionErrors.IntegersRequired)
            return
        }
        
        if Set(players).count != 4 {
            completion(FirebaseSessionErrors.DuplicateNamesInputForGame)
            return
        }
        
        curLeague.add(game: Game(team1: Array(uids[0..<2]), team2: Array(uids[2..<4]), scores: [Int(scores[0])!, Int(scores[1])!], inputter: inputter), completion: { error in
            completion(error)
        })
    }
    
    public func deleteGames(fromLeague league: League, games: [Game], completion: ((Error?) -> Void)? = nil) {
//        let group = DispatchGroup()
//        for game in games {
//            group.enter()
//            Database.database().reference(withPath: "leagues/\(league.id.uuidString)/games/\(game.id)").removeValue() { error, ref in
//                if let error = error {
//                    completion?(error)
//                    return
//                }
//                group.leave()
//            }
//        }
//
//        group.notify(queue: .main) {
//            League.getLeagueFromFirebase(forLeagueID: league.id.uuidString, forDisplay: false, shouldGetGames: true, callback: { leagueOnline in
//                guard let leagueOnline = leagueOnline else {
//                    completion?(FirebaseSessionErrors.LeagueDownloadError) // should i add the game back here?
//                    return
//                }
//                league.setValues(toOtherLeague: leagueOnline)
//                let myGroup = DispatchGroup()
//                var errorFound: Error?
//                let leagueRef = Database.database().reference(withPath: "leagues/\(league.id.uuidString)/players")
//
//                for player in leagueOnline.players {
//                    myGroup.enter()
//                    self.changePlayerRating(leagueRef: leagueRef, newRating: player.rating, playerUID: player.id, completion: { error in
//                        if let error = error {
//                            errorFound = error
//                        }
//                        myGroup.leave()
//                    })
//                }
//                myGroup.notify(queue: .main) {
//                    completion?(errorFound)
//                }
//            })
//        }
    }
    
    public func recalculateRankings(forLeague curLeague: League) {
//        curLeague.recalculateRankings(callback: { gamesToUpload in
//            self.uploadGames(forLeague: curLeague, games: gamesToUpload)
//
//            let leagueRef = Database.database().reference(withPath: "leagues/\(curLeague.id.uuidString)/players")
//
//            for player in curLeague.players.values {
//                self.changePlayerRating(leagueRef: leagueRef, newRating: player.rating, playerUID: player.id)
//            }
//        })
        print("not implemented")
    }
    
    public func changePlayer(inLeague curLeague: League, newDisplayName: String?, newImage: UIImage?, forPlayer player: PlayerForm, completion: @escaping (Error?) ->()) {
        let group = DispatchGroup()
        var errorFound: Error?
        if let newDisplayName = newDisplayName, newDisplayName != player.displayName {
            group.enter()
            changeDisplayName(forLeague: curLeague, newDisplayName: newDisplayName, forPlayer: player, completion: { error in
                if let error = error {
                    errorFound = error
                }
                group.leave()
            })
        }
        
        if let newImage = newImage {
            group.enter()
            changePlayerImage(forLeague: curLeague, newImage: newImage, forPlayer: player, completion: { error in
                if let error = error {
                    errorFound = error
                }
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            completion(errorFound)
        }
    }
    
    public func addDemoPlayer(leagueID: String, displayName: String, realName: String, image: UIImage?, phoneNumber: String, completion: @escaping (Error?) -> ()) {
        
        // Called by JoinLeague.swift. Add the current user to the league
        checkNewPlayer(displayName: displayName, leagueID: leagueID, completion: { error in
            if let error = error {
                completion(error)
                return
            }
            League.newPlayerDict(leagueID, playerID: phoneNumber, realName, phoneNumber, displayName, image ?? Constants.defaultPlayerPhoto, completion: { playerDict in
                    
                var write = [String: Any]()
                let playersPath = "leagues/\(leagueID)/players"
                
                write["\(playersPath)/objects/\(phoneNumber)"] = playerDict
                write["\(playersPath)/displayNames/\(displayName)"] = true
                write["\(playersPath)/playerIDs/\(phoneNumber)"] = true
                
                write["demoUsers/\(phoneNumber)/joinedLeagues/\(leagueID)"] = true
            
                Database.database().reference().updateChildValues(write) { error, ref in
                    completion(error)
                }
            })
        })
    }
    
    public func leaveLeague(fromLeague league: League, completion: @escaping (Error?) -> ()) {
        self.userRef.child("joinedLeagues/\(league.id)").removeValue() { error, ref in
            completion(error)
        }
    }
    
    public func remove(player: PlayerForm, fromLeague league: League, shouldDeletePlayerGames: Bool, shouldDeleteInputGames: Bool, completion: @escaping (Error?) -> ()) {
        
//        if !shouldDeletePlayerGames {
//            if shouldDeleteInputGames {
//                completion(FirebaseSessionErrors.GamesInputButNotPlayed)
//            }
//        }
//        
//        if league.ownsLeague(userID: player.id) {
//            completion(FirebaseSessionErrors.UserOwnsLeague(leagueName: league.name))
//            return
//        }
//        
//        let group = DispatchGroup()
//        var errorFound: Error?
//        
//        
//        
//        group.enter()
//        addLeagueDeletion(toPlayer: player, forLeagueID: league.id.uuidString, forLeagueName: league.name, completion: { error in
//            let arr = [player.displayName, player.realName, player.phoneNumber]
//            Database.database().reference(withPath: "leagues/\(league.id)/blockedUsers/\(player.id)").setValue(arr) { error, ref in
//                if let error = error {
//                    errorFound = error
//                }
//                league.blockedPlayers[player.id] = arr
//                group.leave()
//            }
//        })
//        
//        group.notify(queue: .main) {
//            completion(errorFound)
//        }
    }
    
    public func delete(leagueID: String, completion: @escaping (Error?) ->()) {
        guard let session = self.session else {
            completion(FirebaseSessionErrors.ErrorGettingUser)
            return
        }
        
        var writeObject = [String: Any]()
        writeObject["users/\(session.uid)/ownedLeagues/\(leagueID)"] = [:]
        writeObject["leagues/\(leagueID)"] = [:]
        
        Database.database().reference().updateChildValues(writeObject) { error, ref in
            completion(error)

            //NEED TO REMOVE ENTIRE LOCAL IMAGE GROUP AND ALL IMAGES ASSOCIATED

//            self.storageRef.child(leagueID).listAll(completion: { result, error in
//                if let error = error {
//                   print(error.localizedDescription)
//                }
//                let viewContext = SceneDelegate.persistentContainer.viewContext
//                result.items.forEach({ imageRef in
//                    imageRef.delete()
//                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalImage")
//                    let predicate = NSPredicate(format: "id == %@", imageRef.fullPath)
//                    request.predicate = predicate
//
//                    do {
//                        let fetch = try viewContext.fetch(request)
//                        if let localImage = fetch.first as? LocalImage {
//                            viewContext.delete(localImage)
//                        }
//                    } catch {
//                        print("failed to delete image")
//                    }
//                })

        }
    }
    
    
//    public func delete(leagueID: String, completion: @escaping (Error?) -> ()) {
        //TODO: Go through and delete the league images and player images
        
//        League.getLeagueFromFirebase(forLeagueID: leagueID, forDisplay: false, shouldGetGames: false, callback: { league in
//            guard let league = league else {
//                completion(FirebaseSessionErrors.LeagueDownloadError)
//                return
//            }
//            let players = league.players
//            let creatorUID = league.creatorUID
//            
//            let myGroup = DispatchGroup()
//            for player in players {
//                if player.key != creatorUID {
//                    myGroup.enter()
//                    self.addLeagueDeletion(toPlayer: player.value, forLeagueID: league.id.uuidString, forLeagueName: league.name, completion: { error in
//                        if let error = error {
//                            completion(error)
//                            return
//                        }
//                        myGroup.leave()
//                    })
//                }
//            }
//            myGroup.notify(queue: .main) {
//                Database.database().reference(withPath: "leagues/\(league.id)").removeValue() { error, ref in
//                    if let error = error {
//                        print("error deleting league")
//                        completion(error) // should maybe do something here if the league wasnt deleted
//                        return
//                    }
//                    
//                    //NEED TO REMOVE ENTIRE LOCAL IMAGE GROUP AND ALL IMAGES ASSOCIATED
//                    
//                    self.storageRef.child(leagueID).listAll(completion: { result, error in
//                        if let error = error {
//                           print(error.localizedDescription)
//                        }
//                        result.items.forEach({ imageRef in
//                            imageRef.delete()
//                        })
//                    })
//                    
//                    
//                    self.leagues.removeAll {$0 == league}
//                    print("deleted \(league.id)")
//                    
//                    self.userRef.child("ownedLeagues/\(league.id)").removeValue()
//                        { error, ref in // potential error here where you never remove from ownedleagues
//                            if let error = error {
//                                completion(error)
//                                return
//                            }
//                        completion(nil)
//                            
//                    }
//                            
//                }
//            }
//        })
//    }
    
    public func edit(league: League, newName: String?, newImage: UIImage?, completion: @escaping (Error?) -> ()) {
//        let group = DispatchGroup()
//        var errorFound: Error?
//        if let newName = newName, newName != league.name {
//            group.enter()
//            if let error = checkLeagueNameAvailable(name: newName) {
//                errorFound = error
//                group.leave()
//            } else {
//                Database.database().reference(withPath: "leagues/\(league.id)/leagueName").setValue(newName) { error, ref in
//                    if let error = error {
//                        errorFound = error
//                    } else {
//                        league.name = newName
//                    }
//                    group.leave()
//                }
//            }
//        }
//        
//        if let newImage = newImage {
//            group.enter()
//            league.changeLeagueImage(newImage: newImage, callback: { didUpload in
//                if !didUpload {
//                    errorFound = FirebaseSessionErrors.ImageUploadError
//                }
//                // NEED TO CHANGE LOCAL IMAGE
//                group.leave()
//            })
//        }
//        
//        group.notify(queue: .main) {
//            completion(errorFound)
//        }
    }
    
    public func unblock(userID: String, fromLeague league: League, completion: @escaping (Error?) -> ()) {
//        Database.database().reference(withPath: "leagues/\(league.id)/blockedUsers/\(userID)").removeValue() { error, ref in
//            if let error = error {
//                completion(error)
//                return
//            }
//            league.blockedPlayers.removeValue(forKey: userID)
//            completion(nil)
//        }
    }
    
    // MARK: - Private Helper Functions
    
//    private func uploadToStorage(localImageGroup: LocalImageGroup, firebasePath: String, id: String, image: UIImage, imageChangeDate: Int64) {
//        let playerImageRef = self.storageRef.child(firebasePath)
//        StorageService.uploadImage(image, at: playerImageRef) { (downloadURL) in
//            if downloadURL != nil {
//              print("In uploadLeague: uploaded player image")
//              let localImage = LocalImage(context: self.container.viewContext)
//              localImage.data = image.pngData()
//              localImage.imageChangeDate = imageChangeDate
//              localImage.id = id
//              localImage.localImageGroup = localImageGroup
//              self.saveContext()
//            }else{
//              print("could not upload image at \(firebasePath)")
//          }
//       }
//    }
    
    private func addLeagueDeletion(toPlayer player: PlayerForm, forLeagueID leagueID: String, forLeagueName name: String, completion: @escaping (Error?) ->()) {
        if player.id == player.phoneNumber {
            Database.database().reference(withPath: "demoUsers/\(player.id)/leagueDeletions/\(leagueID)").setValue(name) { error, ref in
                completion(error)
            }
        } else {
            Database.database().reference(withPath: "users/\(player.id)/leagueDeletions/\(leagueID)").setValue(name) { error, ref in
                completion(error)
            }
        }
    }
    
    private func logUserIn(_ user: FirebaseAuth.User, completion: @escaping (Error?) -> ()) {
        
        self.userRef = Database.database().reference(withPath: "users/\(user.uid)")
        let myGroup = DispatchGroup()
              
        var errorFound: Error?
      
        self.session = User(uid: user.uid, realName: user.displayName, phoneNumber: user.phoneNumber, leagueNames: [])
                      
        myGroup.enter()
        self.getLeagues(completion: { error in
            if let error = error {
                errorFound = error
            }
            myGroup.leave()
        })
      
        myGroup.notify(queue: .main) {
            self.isLoggedIn = true
            completion(errorFound)
        }
    }
    
    private func checkDelete(completion: @escaping () -> ()) {
        completion()
        // Called every time the user logs in. Checks to see if they have any league deletions scheduled.
        // The idea with league deletions is that its the one spot that other users can write to,
        // and the user will not delete the league from joinedLeagues unless they actually can't find the league
        
//        userRef.child("leagueDeletions").observeSingleEvent(of: .value, with: { snapshot in // THIS SHOULD BE AN OBSERVE IN CASE SOMEONE WRITES MIDWAY
//            if !snapshot.exists() { // have deletions to do
//                completion()
//                return
//            }
//
//            let deleteGroup = DispatchGroup()
//            let enumerator = snapshot.children
//            while let rest = enumerator.nextObject() as? DataSnapshot {
//                deleteGroup.enter()
//                League.getLeagueFromFirebase(forLeagueID: rest.key, forDisplay: false, shouldGetGames: false, callback: { league in
//                    if league == nil {
//                        self.userRef.child("joinedLeagues/\(rest.key)").removeValue() { error, ref in
//                            deleteGroup.leave()
//                        }
//                    }else {
//                        deleteGroup.leave()
//                    }
//                })
//            }
//            deleteGroup.notify(queue: .main) {
//                self.userRef.child("leagueDeletions").removeValue()
//                completion()
//            }
//
//        })
    }
    
    private func getLeagues(completion: @escaping (Error?) -> ()) {
//        checkDelete {
           self.leagues = []
           let myGroup = DispatchGroup()
           
           var errorFound: Error?
           
           myGroup.enter()
            self.getLeaguesHelper(fromRef: self.userRef.child("ownedLeagues"), completion: { error in
               myGroup.leave()
               errorFound = error
           })
           
            myGroup.enter()
            self.getLeaguesHelper(fromRef: self.userRef.child("joinedLeagues"), completion: { error in
               myGroup.leave()
               errorFound = error
           })
           
           myGroup.notify(queue: .main) {
               completion(errorFound)
           }
//        }
    }
    
    private func getLeaguesHelper(fromRef userLeaguesRef: DatabaseReference, completion: @escaping (Error?) -> ()) {
        userLeaguesRef.observe(.childAdded) { [weak self] snapshot in
            if !snapshot.exists() {
                print("no snapshot for league")
                completion(nil)
                return
            }
                        
            self?.getLeague(leagueID: snapshot.key, completion: { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
        }
        
        userLeaguesRef.observe(.childRemoved) { [weak self] snapshot in
            print("removing league")
            
            self?.leagues.removeAll(where: {$0.id.uuidString == snapshot.key})
        }
    }
    
    private func getLeague(leagueID: String, completion: @escaping (Error?) -> ()) {
        guard let id = UUID(uuidString: leagueID), let league = League(id: id) else {
            print("failed in getLeague")
            return
        }
                        
        self.leagues.append(league)
        
//        League.getLeagueFromFirebase(forLeagueID: leagueID, forDisplay: true, shouldGetGames: true, callback: { league in
//            if let league = league {
//                self.session?.leagueNames.append(name)
//                self.leagues.append(league)
//                completion(nil)
//                return
//
//            } else {
//                completion(FirebaseSessionErrors.LeagueDownloadError)
//            }
//        })
    }
    
//    private func uploadGames(forLeague curLeague: League, games: [[Game]], completion: ((Error?) -> Void)? = nil) {
//        let leagueRef = Database.database().reference(withPath: "leagues/\(curLeague.id.uuidString)/players")
//        let myGroup = DispatchGroup()
//
//        for i in 0..<games.count {
//            let userIDs = games[i][0].team1 + games[i][0].team2 // the players will be the same for each game
//            for j in 0..<games[i].count {
//                myGroup.enter()
//                leagueRef.child("\(userIDs[j])/games/\(games[i][j].date)").setValue(games[i][j].toAnyObject()) { error, ref in
//                    if let error = error {
//                        completion?(error)
//                    } else {
//                        myGroup.leave()
//                    }
//                }
//            }
//        }
//
//        myGroup.notify(queue: .main) {
//            completion?(nil)
//        }
//    }
    
    private func addPlayer(toLeague league: League, displayName: String?, image: UIImage?, userID: String, realName: String, phoneNumber: String, completion: @escaping (Error?) -> ()) {
        
//        checkDisplayName(forLeagueID: league.id.uuidString, newDisplayName: displayName, completion: { error in
//            if let error = error {
//                completion(error)
//                return
//            }
//            
//            let rating = GameInfo.DefaultGameInfo.DefaultRating
//            let player = PlayerForm(uid: userID, displayName: displayName!, image: image, rank: 1, rating: rating, playerGames: [], realName: realName, numPlacementsRequired: league.numPlacements, phoneNumber: phoneNumber)
//            
//            Database.database().reference(withPath: "leagues/\(league.id)/players").updateChildValues(["\(userID)": player.toAnyObject()]) { error, ref in
//                if let error = error {
//                    completion(error)
//                    return
//                }
//                league.displayNameToUserID[player.displayName] = userID
//                league.players[userID] = player
//                league.rankPlayers()
//
//                // NEED TO UPLOAD TO LOCAL IMAGE REF
//                let playerImageRef = self.storageRef.child("\(league.id)/\(userID).jpg")
//                if let image = image {
//                    StorageService.uploadImage(image, at: playerImageRef, completion: {_ in
//                        completion(nil)
//                    })
//                }else {
//                    league.players[userID]?.image = Constants.defaultPlayerPhoto
//                    completion(nil)
//                }
//            }
//        })
    }
    
    private func getOnlineRatings(leagueRef: DatabaseReference, curLeague: League, players: [PlayerForm], completion: @escaping ([String: Rating]?) -> ()) {
        var ratings: [String: Rating] = [:]
        let myGroup = DispatchGroup()
        
        for player in players {
            myGroup.enter()
            let playerGroup = DispatchGroup()
            
            let playerRef = leagueRef.child("\(player.id)")
            
            var mean = player.rating.Mean
            var standardDeviation = player.rating.StandardDeviation
            
            playerGroup.enter()
            playerRef.child("mu").observeSingleEvent(of: .value, with: { (snapshot) in
              // Get user value
                guard let mu = snapshot.value as? Double else {
                    completion(nil)
                    return
                }
                mean = mu
                playerGroup.leave()
            }) { (error) in
                completion(nil)
                return
            }
            
            playerGroup.enter()
            playerRef.child("sigma").observeSingleEvent(of: .value, with: { (snapshot) in
                guard let sigma = snapshot.value as? Double else {
                    completion(nil)
                    return
                }
                standardDeviation = sigma
                playerGroup.leave()
            }) { (error) in
                completion(nil)
                return
            }
            playerGroup.notify(queue: .main) {
                ratings[player.id] = Rating(mean: mean, standardDeviation: standardDeviation)
                myGroup.leave()
            }
        }
            
        myGroup.notify(queue: .main) {
            completion(ratings)
            
        }
        
    }
    
    private func changePlayerRating(leagueRef: DatabaseReference, newRating: Rating, playerUID: String, completion: ((Error?) -> Void)? = nil) {
        let myGroup = DispatchGroup()
        myGroup.enter()
        myGroup.enter()
        
        leagueRef.child("\(playerUID)/mu").setValue(newRating.Mean) { error, ref in
            if let error = error {
                completion?(error)
            }else{
                myGroup.leave()
            }
        }
        
        leagueRef.child("\(playerUID)/sigma").setValue(newRating.StandardDeviation) { error, ref in
            if let error = error {
                completion?(error)
            }else{
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main) {
            completion?(nil)
        }
    }

    private func checkDisplayName(forLeagueID leagueID: String?, newDisplayName: String?, completion: @escaping (Error?) -> ()) {
        
//        guard let newDisplayName = newDisplayName else {
//            completion(FirebaseSessionErrors.BlankDisplayName)
//            return
//        }
//
//        if newDisplayName == "" {
//            completion(FirebaseSessionErrors.BlankDisplayName)
//            return
//        }
//
//        if newDisplayName.count > Constants.maxCharacterDisplayName {
//            completion(FirebaseSessionErrors.DisplayNameTooLong)
//            return
//        }
//
//        guard let leagueID = leagueID else {
//            completion(nil)
//            return
//        }
//
//        //Redownload league just to make sure no one else has changed their display name to what we are trying
//        League.getLeagueFromFirebase(forLeagueID: leagueID, forDisplay: false, shouldGetGames: false, callback: { league in // MAYBE I SHOULD HAVE A DISPLAYNAMES TAB
//            if let league = league {
//                for player in league.sortedPlayers {
//                    if player.displayName == newDisplayName {
//                        completion(FirebaseSessionErrors.DisplayNameTaken(name: newDisplayName))
//                        return
//                    }
//                }
//                completion(nil)
//            } else {
//               completion(FirebaseSessionErrors.LeagueDownloadError)
//           }
//        })
    }
    
    private func changeDisplayName(forLeague curLeague: League, newDisplayName: String, forPlayer player: PlayerForm, completion: @escaping (Error?) -> ()) {
        
//        checkDisplayName(forLeagueID: curLeague.id.uuidString, newDisplayName: newDisplayName, completion: { error in
//            if let error = error {
//                completion(error)
//                return
//            }
//            // no one has the name so tell the league to change the display name
//            curLeague.changePlayerDisplayName(uid: player.id, newDisplayName: newDisplayName, callback: { error in
//                if let error = error {
//                    completion(error)
//                    return
//                }
//
//                completion(nil)
//
//            })
//        })
    }
    
    private func changePlayerImage(forLeague curLeague: League, newImage: UIImage, forPlayer player: PlayerForm, completion: @escaping (Error?) -> ()) {
//        curLeague.changePlayerImage(player: player, newImage: newImage, callback: { didUploadImage in
//            if didUploadImage {
//                player.image = newImage
//                completion(nil)
//            } else {
//                completion(FirebaseSessionErrors.ImageUploadError)
//                return
//            }
//        })
    }
    
//    func redoLeague(forLeague curLeague: League) {
//        curLeague.returnGamesWithUserIDs(callback: { gamesToUpload in
//            self.uploadGames(forLeague: curLeague, games: gamesToUpload)
//
//            let leagueRef = Database.database().reference(withPath: "\(curLeague.id.uuidString)/players")
//
//            for player in curLeague.players.values {
//                self.changePlayerRating(leagueRef: leagueRef, newRating: player.rating, playerUID: player.id)
//            }
//        })
//    }
//

}

extension FirebaseSession.FirebaseSessionErrors {
    public var errorDescription: String? {
        switch self {
        case .LeagueDownloadError:
            return NSLocalizedString("Failed to download league", comment: "My error")
        case .PlayerScoreDownloadError:
            return NSLocalizedString("Failed to get online player rankings", comment: "My error")
        case .UploadGameError:
            return NSLocalizedString("Failed to upload game", comment: "My error")
        case .ProfileDownloadError:
            return NSLocalizedString("Failed to download profile", comment: "My error")
        case .DisplayNameTaken(name: let name):
            return NSLocalizedString("The name \(name) is taken", comment: "My error")
        case .BlankDisplayName:
            return NSLocalizedString("You entered a blank username", comment: "My error")
        case .DisplayNameTooLong:
            return NSLocalizedString("Usernames can not be longer than \(Constants.maxCharacterDisplayName) length", comment: "My error")
        case .ImageUploadError:
            return NSLocalizedString("Failed to upload image", comment: "My error")
        case .InvalidPhoneNumber(phoneNumber: let phoneNumber):
            return NSLocalizedString("\(phoneNumber) is not a valid phone number", comment: "My error")
        case .UserDoesntOwnLeague(leagueName: let leagueName, phoneNumber: let phoneNumber):
            return NSLocalizedString("The user with phone number \(phoneNumber) does not own a league called \(leagueName)", comment: "My error")
        case .ErrorGettingUser:
            return NSLocalizedString("Failed to find user", comment: "My error")
        case .AlreadyJoinedLeague(leagueName: let leagueName, phoneNumber: let phoneNumber):
            return NSLocalizedString("You are already a part of \(phoneNumber)'s league \(leagueName)", comment: "My error")
        case .LeagueNameNotAvailable(leagueName: let leagueName):
            return NSLocalizedString("You already have a league called \(leagueName)", comment: "My error")
        case .UserOwnsLeague(leagueName: let leagueName):
            return NSLocalizedString("This user owns \(leagueName) so you cant remove them", comment: "My error")
        case .GamesInputButNotPlayed:
            return NSLocalizedString("You can't delete games input and not games played", comment: "My error")
        case .RejoinTriedIncorrectly:
            return NSLocalizedString("Tried to rejoin a league that my user id isnt a part of", comment: "My error")
        case .InvalidDisplayName(inLeagueName: let inLeagueName, displayName: let displayName):
            return NSLocalizedString("\(displayName) is not a member of \(inLeagueName)", comment: "My error")
        case .DuplicateNamesInputForGame:
            return NSLocalizedString("Duplicate names input", comment: "My error")
        case .IntegersRequired:
            return NSLocalizedString("Input must be numbers", comment: "My error")
        }
    }
} 

