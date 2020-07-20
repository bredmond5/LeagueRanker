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

class FirebaseSession: ObservableObject {
    
    //MARK: Properties
    @Published var session: User?
    @Published var isLoggedIn: Bool?
    
    @Published var leagues: [League] = []
    @Published var curLeague = League()
    
    var myAlerts: MyAlerts

    var ref: DatabaseReference = Database.database().reference()
    
    init() {
        ref = Database.database().reference(withPath: "\(String(describing: Auth.auth().currentUser?.phoneNumber ?? "Error"))")
        myAlerts = MyAlerts()
    }
    
    var storageRef = Storage.storage().reference()
    
     func login(withPhoneNumber finalPhone: String) {
            PhoneAuthProvider.provider().verifyPhoneNumber(finalPhone, uiDelegate: nil) { (verificationID, error) in
                  if let error = error {
                    self.myAlerts.showMessagePrompt(title: "Error", message: error.localizedDescription, callback: {})
                    return
                  }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                self.myAlerts.showTextInputPrompt(title: "Enter code sent to iPhone", message: "", callback: { userPressedOk, code in
                    if userPressedOk {
                        self.finishLogin(withCode: code)
                    }
                })
            }
        }
        
        func finishLogin(withCode verificationCode: String) {
            let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
            let isMFAEnabled = true
                        
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID!,
            verificationCode: verificationCode)
                        
            Auth.auth().signIn(with: credential) { (authResult, error) in
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
                    self.myAlerts.showTextInputPrompt(title: "Select factor to sign in\n\(displayNameString)", message: "", callback: { userPressedOk, displayName in
                        
                    var selectedHint: PhoneMultiFactorInfo?
                    for tmpFactorInfo in resolver.hints {
                      if (displayName == tmpFactorInfo.displayName) {
                        selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                      }
                    }
                    PhoneAuthProvider.provider().verifyPhoneNumber(with: selectedHint!, uiDelegate: nil, multiFactorSession: resolver.session) { verificationID, error in
                      if let error = error {
                        self.myAlerts.showMessagePrompt(title: "Error", message: error.localizedDescription, callback: {})
                      } else {
                        self.myAlerts.showTextInputPrompt(title: "Verification code for \(selectedHint?.displayName ?? "")", message: "", callback: { userPressedOK, verificationCode in
                          let credential: PhoneAuthCredential? = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: verificationCode)
                          let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator.assertion(with: credential!)
                          resolver.resolveSignIn(with: assertion!) { authResult, error in
                            if let error = error {
                              self.myAlerts.showMessagePrompt(title: "Error", message: error.localizedDescription, callback: {})
                            } else {
    //                          callingView.navigationController?.popViewController(animated: true)
                            }
                          }
                        })
                      }
                    }
                  })
                } else {
                    self.myAlerts.showMessagePrompt(title: "Error", message: error.localizedDescription, callback: {})
                  return
                }
                // ...
                return
              }
            }

        }
    
    //MARK: Functions
    func listen() {
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.ref = Database.database().reference(withPath: "\(String(describing:  Auth.auth().currentUser?.phoneNumber ?? "Error"))")
                self.makeUser(user)
                
                self.isLoggedIn = true
                self.getLeagues()
            } else {
                self.isLoggedIn = false
                self.session = nil
            }
        }
    }
    
    func makeUser(_ user: FirebaseAuth.User) {
        self.session = User(uid: user.uid, displayName: user.displayName ?? "user1234", phoneNumber: user.phoneNumber, image: UIImage(), leagueNames: [])
        
        if(user.photoURL != nil) {
            let r = storageRef.child(self.session!.phoneNumber! + ".jpg")

            r.getData(maxSize: 1 * 1024 * 1024) { data, error in
              if let error = error {
                print(error.localizedDescription)

              } else {
                let image = UIImage(data: data!) ?? UIImage()
                self.session = User(uid: user.uid, displayName: user.displayName ?? "user1234", phoneNumber: self.session?.phoneNumber, image: image, leagueNames: self.session!.leagueNames)
              }
            }
        }
        
        ref.child("displayName").setValue(self.session?.displayName)
        ref.child("uid").setValue(self.session?.uid)
    }
    
    func changeUser(displayName: String = "", image: UIImage?) {
        //Need to go through every league and change the display name, image, and player games
        if(displayName != "") {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = displayName
            changeRequest?.commitChanges { (error) in
                if let error = error {
                    self.myAlerts.showMessagePrompt(title: "Error", message: error.localizedDescription, callback: {})
                } else {
                    self.session!.displayName = displayName
                    self.ref.child("displayName").setValue(displayName)
                    self.myAlerts.showMessagePrompt(title: "Alert", message: "Reload the app to see your display name change in your leagues", callback: {})
                }
            }
        }
        
        if(image != nil) {
            session = User(uid: session!.uid, displayName: session!.displayName, phoneNumber: session!.phoneNumber, image: image!, leagueNames: self.session!.leagueNames)
            let imageRef = storageRef.child(session!.phoneNumber! + ".jpg")
            StorageService.uploadImage(image!, at: imageRef) { (downloadURL) in
                guard let downloadURL = downloadURL else {
                     self.myAlerts.showMessagePrompt(title: "Error", message: "Could not upload user image", callback: {})
                    return
                }
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.photoURL = downloadURL
                
                changeRequest?.commitChanges { (error) in
                    if let error = error {
                        self.myAlerts.showMessagePrompt(title: "Error", message: error.localizedDescription, callback: {})
                    }
                }
                
            }
        }
        
    }
    
    func logOut() {
        try! Auth.auth().signOut()
        self.isLoggedIn = false
        self.session = nil
        self.leagues = []
        self.curLeague = League()
    }
    
    func getLeagues() {
        self.leagues = []
        
        getLeagues(fromRef: ref.child("ownedLeagues"))
        getLeagues(fromRef: ref)
        
    }
    
    func getLeagues(fromRef refForLeagues: DatabaseReference) {
        refForLeagues.observeSingleEvent(of: .value, with: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                if rest.key != "displayName" && rest.key != "uid" && rest.key != "ownedLeagues" {
                    self.getLeague(name: rest.value as! String , path: rest.key, callingFunction: "get leagues")
                
                }
            }
        })
    }
    
    func getLeague(name: String, path: String, callingFunction: String) {
        print("getLeague called by " + callingFunction)
        let locRef = Database.database().reference(withPath: path)
        locRef.observeSingleEvent(of: DataEventType.value) { (locSnapshot) in
            print("opening league: " + path)
            if let league = League(snapshot: locSnapshot, id: path, callingFunction: "getLeague") {
                print("nonnull league")
                self.session?.leagueNames.append(name)
                self.leagues.append(league)
                self.curLeague = self.leagues[0]
                return
            }
        }
    }
    
    func getUserLeagueNames() -> [String] {
        var leagueNames: [String] = []
        for league in leagues {
            if league.creatorPhone == self.session!.phoneNumber! {
                leagueNames.append(league.name)
            }
        }
        return leagueNames
    }
    
    func uploadLeague(leagueName: String, leagueImage: UIImage, displayName: String, playerImage: UIImage) {
        
        let league = League(name: leagueName, image: leagueImage, creatorPhone: self.session!.phoneNumber!, creatorDisplayName: displayName, creatorImage: playerImage)
        
        let leagueRef: DatabaseReference = Database.database().reference().child("\(league.id)")
        leagueRef.setValue(league.toAnyObject())
        
        let leagueImageRef = storageRef.child("\(league.id).jpg")
        StorageService.uploadImage(leagueImage, at: leagueImageRef) { (downloadURL) in
            print("In uploadLeague: uploaded league image")
        }
        
        let playerImageRef = storageRef.child("\(league.id)\(self.session!.phoneNumber!).jpg")
        StorageService.uploadImage(playerImage, at: playerImageRef) { (downloadURL) in
            print("In uploadLeague: uploaded player image")
        }
        
        ref.child("ownedLeagues/\(league.id.uuidString)").setValue("\(league.name)")
        
        leagues.append(league)
        curLeague = leagues[leagues.count - 1]
       
    }
    
    func joinLeague(leagueID: String, leagueName: String, displayName: String, phoneNumber: String, image: UIImage)
    {
        let rating = GameInfo.DefaultGameInfo.DefaultRating
        let addition = ["displayName": displayName, "mu": rating.Mean, "sigma": rating.StandardDeviation] as [String : Any]
        Database.database().reference(withPath: leagueID).updateChildValues(["/players/\(self.session!.phoneNumber!)": addition])
        Database.database().reference(withPath: self.session!.phoneNumber!).updateChildValues(["\(leagueID)": leagueName])
        let playerImageRef = storageRef.child("\(leagueID)\(self.session!.phoneNumber!).jpg")
        StorageService.uploadImage(image, at: playerImageRef, completion: {_ in
            self.getLeague(name: leagueName, path: leagueID, callingFunction: "join league")
        })
    }

    func changeCurLeague(league: League) {
        self.curLeague = League()
        self.curLeague = league
    }
    
    func uploadGame(game: Game, newRatings: [Rating]) {
        let displayNameToPhoneNumber = self.curLeague.displayNameToPhoneNumber
        let leagueRef = Database.database().reference(withPath: "\(curLeague.id.uuidString)/players")
        uploadGame(forPlayer: displayNameToPhoneNumber[game.team1[0]]!, game: game, leagueRef: leagueRef, newRating: newRatings[0])
        uploadGame(forPlayer: displayNameToPhoneNumber[game.team1[1]]!, game: game, leagueRef: leagueRef, newRating: newRatings[1])
        uploadGame(forPlayer: displayNameToPhoneNumber[game.team2[0]]!, game: game, leagueRef: leagueRef, newRating: newRatings[2])
        uploadGame(forPlayer: displayNameToPhoneNumber[game.team2[1]]!, game: game, leagueRef: leagueRef, newRating: newRatings[3])
    }
    
    func uploadGame(forPlayer playerPhone: String, game: Game, leagueRef: DatabaseReference, newRating: Rating) {
        //let playerDisplayName = curLeague.players[playerPhone]!.displayName
        let oldPlayerMean = curLeague.players[playerPhone]!.rating.Mean
        var gameToAdd: Game
//        if game.team2.contains(playerDisplayName) {
//            if Int(game.scores[1])! < Int(game.scores[0])! {
//                gameToAdd = Game(team1: game.team1, team2: game.team2, scores: game.scores, key: "", gameScore: -game.gameScore, date: game.date)
//                leagueRef.child("\(playerPhone)/games/\(gameToAdd.date)").setValue(gameToAdd.toAnyObject())
//            }else{
//                gameToAdd = game
//                leagueRef.child("\(playerPhone)/games/\(gameToAdd.date)").setValue(gameToAdd.toAnyObject())
//            }
//
//        } else {
//            if Int(game.scores[1])! > Int(game.scores[0])! {
//                gameToAdd = Game(team1: game.team1, team2: game.team2, scores: game.scores, key: "", gameScore: -game.gameScore, date: game.date)
//                leagueRef.child("\(playerPhone)/games/\(gameToAdd.date)").setValue(gameToAdd.toAnyObject())
//            }else{
//                gameToAdd = game
//                leagueRef.child("\(playerPhone)/games/\(gameToAdd.date)").setValue(gameToAdd.toAnyObject())
//            }
//        }
        gameToAdd = Game(team1: game.team1, team2: game.team2, scores: game.scores, key: "", gameScore: newRating.Mean - oldPlayerMean, date: game.date)
        leagueRef.child("\(playerPhone)/games/\(gameToAdd.date)").setValue(gameToAdd.toAnyObject())
        leagueRef.child("\(playerPhone)/mu").setValue(newRating.Mean)
        leagueRef.child("\(playerPhone)/sigma").setValue(newRating.StandardDeviation)
        
        curLeague.players[playerPhone]?.playerGames.append(gameToAdd)
        curLeague.players[playerPhone]?.rating = newRating
        curLeague.sortPlayers()
    }
}
