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
//    @Published var curLeague = League()
    
    var myAlerts: MyAlerts

    var ref: DatabaseReference = Database.database().reference()
    
    init() {
        ref = Database.database().reference(withPath: "\(String(describing: Auth.auth().currentUser?.phoneNumber ?? "Error"))")
        myAlerts = MyAlerts()
    }
    
    var storageRef = Storage.storage().reference()
    
    func login(withPhoneNumber finalPhone: String, resignRequired: @escaping (Error) -> ()) {
            PhoneAuthProvider.provider().verifyPhoneNumber(finalPhone, uiDelegate: nil) { (verificationID, error) in
                  if let error = error {
                    resignRequired(error)
                    print(error.localizedDescription)
                    return
                  }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                self.myAlerts.showTextInputPrompt(placeholder: "654321", title: "Enter code sent to iPhone", message: "", keyboardType: .numberPad, callback: { userPressedOk, code in
                    if userPressedOk {
                        self.finishLogin(withCode: code, resignRequired: { error in
                            resignRequired(error)
                        })
                    }
                })
            }
        }
        
    func finishLogin(withCode verificationCode: String, resignRequired: @escaping (Error) -> ()) {
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
                self.myAlerts.showTextInputPrompt(placeholder: "", title: "Select factor to sign in\n\(displayNameString)", message: "", keyboardType: .numberPad, callback: { userPressedOk, displayName in
                    
                var selectedHint: PhoneMultiFactorInfo?
                for tmpFactorInfo in resolver.hints {
                  if (displayName == tmpFactorInfo.displayName) {
                    selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                  }
                }
                PhoneAuthProvider.provider().verifyPhoneNumber(with: selectedHint!, uiDelegate: nil, multiFactorSession: resolver.session) { verificationID, error in
                  if let error = error {
//                    self.myAlerts.showMessagePrompt(title: "Error", message: error.localizedDescription, callback: {})
                    resignRequired(error)
                  } else {
                    self.myAlerts.showTextInputPrompt(placeholder: "", title: "Verification code for \(selectedHint?.displayName ?? "")", message: "", keyboardType: .numberPad, callback: { userPressedOK, verificationCode in
                      let credential: PhoneAuthCredential? = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: verificationCode)
                      let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator.assertion(with: credential!)
                      resolver.resolveSignIn(with: assertion!) { authResult, error in
                        if let error = error {
                          //self.myAlerts.showMessagePrompt(title: "Error", message: error.localizedDescription, callback: {})
                            resignRequired(error)
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
                resignRequired(error)
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
        self.session = User(uid: user.uid, displayName: user.displayName, phoneNumber: user.phoneNumber, image: UIImage(), leagueNames: [])
        
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
                    
                    for league in self.leagues {
                        league.changeRealName(forPlayerPhone: self.session!.phoneNumber!, newName: displayName)
                    }
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
//        self.curLeague = League()
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
                    self.getLeague(name: rest.value as! String , path: rest.key)
                
                }
            }
        })
    }
    
    func getLeague(name: String, path: String) {
        League.getLeagueFromFirebase(forLeagueID: path, forDisplay: true, shouldGetGames: true, callback: { league in
            if let league = league {
                self.session?.leagueNames.append(name)
                self.leagues.append(league)
    //                self.curLeague = self.leagues[0]
                return
            }
        })
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
        let creatorRealName = session!.displayName!
        
        let league = League(leagueName: leagueName, image: leagueImage, creatorPhone: self.session!.phoneNumber!, creatorDisplayName: displayName, creatorRealName: creatorRealName, creatorImage: playerImage)
        
        let leagueRef: DatabaseReference = Database.database().reference().child("\(league.id)")
        leagueRef.setValue(league.toAnyObject())
        
        let leagueImageRef = storageRef.child("\(league.id).jpg")
        StorageService.uploadImage(leagueImage, at: leagueImageRef) { (downloadURL) in
            if downloadURL != nil {
                print("In uploadLeague: uploaded league image")
            }else{
                print("could not upload league image")
            }
        }
        
        let playerImageRef = storageRef.child("\(league.id)\(self.session!.phoneNumber!).jpg")
        StorageService.uploadImage(playerImage, at: playerImageRef) { (downloadURL) in
            if downloadURL != nil {
                print("In uploadLeague: uploaded player image")
            }else{
                print("could not upload player image")
            }
        }
        
        ref.child("ownedLeagues/\(league.id.uuidString)").setValue("\(league.name)")
        
        leagues.append(league)
//        curLeague = leagues[leagues.count - 1]
       
    }
    
    func joinLeague(leagueID: String, leagueName: String, displayName: String, image: UIImage)
    {
        let realName = session!.displayName!
        let rating = GameInfo.DefaultGameInfo.DefaultRating
        let addition = ["realName": realName, "displayName": displayName, "mu": rating.Mean, "sigma": rating.StandardDeviation] as [String : Any]
        Database.database().reference(withPath: leagueID).updateChildValues(["/players/\(self.session!.phoneNumber!)": addition])
        Database.database().reference(withPath: self.session!.phoneNumber!).updateChildValues(["\(leagueID)": leagueName])
        let playerImageRef = storageRef.child("\(leagueID)\(self.session!.phoneNumber!).jpg")
        StorageService.uploadImage(image, at: playerImageRef, completion: {_ in
            self.getLeague(name: leagueName, path: leagueID)
        })
    }

//    func changeCurLeague(league: League) {
//        self.curLeague = League()
//        self.curLeague = league
//    }
    
    func uploadGames(forLeague curLeague: League, games: [[Game]]) {
        let leagueRef = Database.database().reference(withPath: "\(curLeague.id.uuidString)/players")
        
        for i in 0..<games.count {
            let phoneNumbers = games[i][0].team1 + games[i][0].team2 // the players will be the same for each game
            for j in 0..<games[i].count {
                leagueRef.child("\(phoneNumbers[j])/games/\(games[i][j].date)").setValue(games[i][j].toAnyObject())
                
            }
        }
    }
    
    func uploadGame(curLeague: League, game: Game, newRatings: [Rating]) {
        let leagueRef = Database.database().reference(withPath: "\(curLeague.id.uuidString)/players")
                        
        uploadGame(forLeague: curLeague, forPlayer: game.team1[0], game: game, leagueRef: leagueRef, newRating: newRatings[0])
        changePlayerRating(leagueRef: leagueRef, newRating: newRatings[0], playerPhone: game.team1[0])
        
        uploadGame(forLeague: curLeague,forPlayer: game.team1[1], game: game, leagueRef: leagueRef, newRating: newRatings[1])
        changePlayerRating(leagueRef: leagueRef, newRating: newRatings[1], playerPhone: game.team1[1])
        
        uploadGame(forLeague: curLeague,forPlayer: game.team2[0], game: game, leagueRef: leagueRef, newRating: newRatings[2])
        changePlayerRating(leagueRef: leagueRef, newRating: newRatings[2], playerPhone: game.team2[0])
        
        uploadGame(forLeague: curLeague,forPlayer: game.team2[1], game: game, leagueRef: leagueRef, newRating: newRatings[3])
        changePlayerRating(leagueRef: leagueRef, newRating: newRatings[3], playerPhone: game.team2[1])
        
    }
    
    func uploadGame(forLeague curLeague: League, forPlayer playerPhone: String, game: Game, leagueRef: DatabaseReference, newRating: Rating) {
        //let playerDisplayName = curLeague.players[playerPhone]!.displayName
        let oldPlayerMean = curLeague.players[playerPhone]!.rating.Mean
        let oldPlayerSigma = curLeague.players[playerPhone]!.rating.StandardDeviation
        let gameToAdd = Game(team1: game.team1, team2: game.team2, scores: game.scores, key: "", gameScore: newRating.Mean - oldPlayerMean, sigmaChange: newRating.StandardDeviation - oldPlayerSigma, date: game.date, inputter: game.inputter)
        leagueRef.child("\(playerPhone)/games/\(gameToAdd.date)").setValue(gameToAdd.toAnyObject())
        
        curLeague.addPlayerGame(forPlayerPhone: playerPhone, playerGame: gameToAdd, newRating: newRating)
    }
    
    func changePlayerRating(leagueRef: DatabaseReference, newRating: Rating, playerPhone: String) {
        leagueRef.child("\(playerPhone)/mu").setValue(newRating.Mean)
        leagueRef.child("\(playerPhone)/sigma").setValue(newRating.StandardDeviation)
    }
    
    func deleteGame(fromLeague league: League, game: Game, fromPlayer player: PlayerForm) {
        league.deleteGame(forDate: game.date, forPlayer: player, callback: { gamesToUpload in
            let leagueRef = Database.database().reference(withPath: "\(league.id.uuidString)/players/")

            //actually remove the game from the four players on firebase. The deletion of the game from the players locally was done in the league

            for playerPhone in game.team1 + game.team2 {
                leagueRef.child("\(playerPhone)/games/\(game.date)").removeValue()
            }
            
            //upload the games that need to be reuploaded
            self.uploadGames(forLeague: league, games: gamesToUpload)
                        
            for player in league.players.values {
                self.changePlayerRating(leagueRef: leagueRef, newRating: player.rating, playerPhone: player.phoneNumber)
            }
        })
        
//        let displayNameToPhone = league.displayNameToPhoneNumber
        
        
    }
    
    func recalculateRankings(forLeague curLeague: League) {
        curLeague.recalculateRankings(callback: { gamesToUpload in
            self.uploadGames(forLeague: curLeague, games: gamesToUpload)
            
            let leagueRef = Database.database().reference(withPath: "\(curLeague.id.uuidString)/players")
            
            for player in curLeague.players.values {
                self.changePlayerRating(leagueRef: leagueRef, newRating: player.rating, playerPhone: player.phoneNumber)
            }
        })
    }
    
    func redoLeague(forLeague curLeague: League) {
        curLeague.returnGamesWithPhoneNumbers(callback: { gamesToUpload in
            self.uploadGames(forLeague: curLeague, games: gamesToUpload)
            
            let leagueRef = Database.database().reference(withPath: "\(curLeague.id.uuidString)/players")
            
            for player in curLeague.players.values {
                self.changePlayerRating(leagueRef: leagueRef, newRating: player.rating, playerPhone: player.phoneNumber)
            }
        })
    }
    
    //        var newRatingsArr: [[Rating]] = []
    //        var gamesToUpload: [Game] = []
    //        for (_, value) in allGamesAfterDate.sorted(by: { $0.0 > $1.0 }) {
    //            let newRatings = Functions.getNewRatings(players: value.team1 + value.team2, scores: value.scores, ratings: [playerDict[displayNameToPhone[value.team1[0]]!]!.rating, playerDict[displayNameToPhone[value.team1[1]]!]!.rating, playerDict[displayNameToPhone[value.team2[0]]!]!.rating, playerDict[displayNameToPhone[value.team2[1]]!]!.rating])
    //            newRatingsArr.append(newRatings)
    //            gamesToUpload.append(value)
    //        }
}
