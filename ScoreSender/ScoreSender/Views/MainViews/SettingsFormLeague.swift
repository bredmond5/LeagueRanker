//
//  SettingsFormLeague.swift
//  ScoreSender
//
//  Created by Brice Redmond on 7/30/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI
import Combine

struct SettingsFormLeague: View {
    @EnvironmentObject var session: FirebaseSession // for finding the player in the league
    
    weak var curPlayer: PlayerForm?
    @ObservedObject var curLeague: League
        
    @State private var keyboardHeight: CGFloat = 0
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    @State var showingAlert = false
    @State var alertMessage = "" {
        didSet {
            showingAlert = true
        }
    }
    
    @State var showingTextFieldAlert: Bool? = false
    
    @State var isPresentingChangeProfileModal: Bool = false
    @State var isPresentingDemoPlayerModal: Bool = false
    @State var isPresentingEditLeagueModal: Bool = false
    @State var realName = ""
    @State var phoneNumber = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Creator phone number: \(curLeague.owner?.phoneNumber ?? "")")
                .fontWeight(.heavy)
                .font(.system(size: 16))
            
            if curPlayer != nil {
            
                Button(action: { self.isPresentingChangeProfileModal.toggle() }) {
                    SpanningLabel(color: .blue, content: "Edit Profile")
                }.alert(isPresented: self.$showingAlert, content: {
                    Alert(title: Text(self.alertMessage))
                }).sheet(isPresented: $isPresentingChangeProfileModal, content: {
                    DisplayNameAndPhoto(username: self.curPlayer!.displayName, image: self.curPlayer!.dbImage.image, isPresented: self.$isPresentingChangeProfileModal, title: "Edit Profile", userFinished: { displayName, image, userFinished in
                        self.session.changePlayer(inLeague: self.curLeague, newDisplayName: displayName, newImage: image, forPlayer: self.curPlayer!, completion: { error in
                            userFinished(error)
                        })
                    })
                })
                
    //            NavigationLink(destination: DisplayNameAndPhoto(session: self._session, username: self.curPlayer.displayName, image: self.curPlayer.image, userFinished: { displayName, image, userFinished in
    //                    self.session.changePlayer(inLeague: self.curLeague, newDisplayName: displayName, newImage: image, forPlayer: self.curPlayer, completion: { error in
    //                        userFinished(error)
    //                        if error == nil {
    //                            self.mode.wrappedValue.dismiss()
    //                        }
    //                    })
    //                }
    ////            ).navigationBarTitle("Edit Profile")) {
    //            )){
    //                SpanningLabel(color: .blue, content: "Edit profile")
    //            }
    //
                    
    //            Button(action: { self.isPresentingModal.toggle() }) {
    //                SpanningLabel(color: .blue, content: "Edit profile")
    //            }.sheet(isPresented: $isPresentingModal, content: {
    //
    //            })
                
    //            Button(action: redoLeague) {
    //                SpanningLabel(color: .red, content: "Switch to phone Numbers")
    //            }
        
                if curLeague.ownsLeague(userID: session.session!.uid) {
                    Text("League owner actions:")
                    NavigationLink(destination: UnblockPlayers(curLeague: curLeague)) {
                        SpanningLabel(color: .blue, content: "Unblock players")
                    }
                    
                    Button(action: { self.isPresentingEditLeagueModal.toggle() }) {
                        SpanningLabel(color: .blue, content: "Edit League")
                    }.alert(isPresented: self.$showingAlert, content: {
                        Alert(title: Text(self.alertMessage))
                    }).sheet(isPresented: $isPresentingEditLeagueModal, content: {
                        DisplayNameAndPhoto(username: self.curLeague.name, image: self.curLeague.image, isPresented: self.$isPresentingEditLeagueModal, title: "Edit League", userFinished: { newName, image, userFinished in
                            self.session.edit(league: self.curLeague, newName: newName, newImage: image, completion: { error in
                                userFinished(error)
                            })
                        })
                    })
                    
                    Button(action: {
                        self.realName = ""
                        self.phoneNumber = ""
                        MyAlerts().showTextInputPrompt(placeholder: "6505551234", title: "Enter the demo user's phone number", message: "This is so that the user can eventually claim their leagues", keyboardType: .default, callback: { userPressedEnter, phoneNumber in
                            if userPressedEnter {
                                self.phoneNumber = "+1\(phoneNumber)"
                                if self.curLeague.player(atPhoneNumber: phoneNumber) != nil {
                                    self.alertMessage = "\(self.curLeague.player(atPhoneNumber: phoneNumber)!.displayName) is already using that phone number"
                                    return
                                }
                                MyAlerts().showTextInputPrompt(placeholder: "Real Name", title: "This is used for putting non iPhone users in a league", message: "Enter their real name", keyboardType: .default, callback: { userPressedEnter, name in
                                    if userPressedEnter {
                                        self.realName = name
                                        self.isPresentingDemoPlayerModal = true
                                    }
                                    
                                })
                            }
                        })
                        
                    }) {
                        SpanningLabel(color: .blue, content: "Create Demo Player")
                    }
                    .sheet(isPresented: $isPresentingDemoPlayerModal, content: {
                        DisplayNameAndPhoto(username: self.realName, image: nil, isPresented: self.$isPresentingDemoPlayerModal, title: "Demo Player", userFinished: { displayName, image, userFinished in
                            self.session.addDemoPlayer(leagueID: self.curLeague.id.uuidString, displayName: displayName, realName: self.realName, image: image, phoneNumber: self.phoneNumber, completion: { error in
                                userFinished(error)
                            })
                        })
                    })
                    
                    Button(action: {
                        MyAlerts().showTextInputPrompt(placeholder: "", title: "Delete league", message: "Enter the name of the league to delete it", keyboardType: .default, callback: { userPressEnter, name  in
                            if userPressEnter {
                                if name != self.curLeague.name {
                                    self.alertMessage = "Incorrect league name"
                                    return
                                }
                                
                                self.session.delete(leagueID: self.curLeague.id.uuidString, completion: { error in
                                    if let error = error {
                                        print(error.localizedDescription)
                                        self.alertMessage = error.localizedDescription
                                    } else {
                                        self.mode.wrappedValue.dismiss()
                                    }
                                })
                            }
                        })
                    }) {
                        SpanningLabel(color: .red, content: "Delete League")
                    }.alert(isPresented: $showingAlert) {
                        Alert(title: Text(alertMessage))
                    }
                    
                    NavigationLink(destination: RemovePlayer(session: _session, curLeague: curLeague)) {
                        SpanningLabel(color: .red, content: "Remove Player")
                    }
                    
                     
                    Button(action: { self.showingAlert.toggle() }) {
                        SpanningLabel(color: .red, content: "Recalculate Rankings")
                    }.alert(isPresented: $showingAlert) {
                        Alert(title: Text("Recalculate Rankings"), message: Text("This button should be used if you suspect that the rankings may have been corrupted"), primaryButton: .default(Text("Go")) {
                            self.resetRankings()
                        }, secondaryButton: .cancel())
                    }
                } else {
                    /*
                    Button(action: {
                       MyAlerts().showTextInputPrompt(placeholder: "", title: "Leave league", message: "Enter the name of the league to leave it", keyboardType: .default, callback: { userPressEnter, name  in
                           if userPressEnter && name == self.curLeague.name {
                               print("Leaving!")
                           }
                       })
                   }) {
                       SpanningLabel(color: .red, content: "Leave League")
                   }
                     */
                }
                Spacer()
                }
            }
            .padding(.all, 12)
            .navigationBarTitle("Settings")
            .onReceive(Publishers.keyboardHeight, perform: {self.keyboardHeight = $0})
    }
    
    func resetRankings() {
        session.recalculateRankings(forLeague: curLeague)
    }
    
//    func redoLeague() {
//        session.redoLeague(forLeague: curLeague)
//    }
}

