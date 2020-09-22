//
//  RemovePlayer.swift
//  ScoreSender
//
//  Created by Brice Redmond on 8/30/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct RemovePlayer: View {
    @EnvironmentObject var session: FirebaseSession
    
    let curLeague: League
    
    @State var displayName: String = ""
    @State var isResponder: Bool? = true
    
    @State var showingAlert = false
    @State var alertMessage = "" {
        didSet {
            showingAlert = true
        }
    }
    
    @State var removePlayerGames = false
    @State var removePlayerGamesAlert = false
    
    @State var removePlayerInputGames = false
    @State var removePlayerInputGamesAlert = false
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    
    var datasource: [String: String] {
        let players = curLeague.returnPlayers()
        var datasource: [String: String] = [:]
        var duplicates: [String] = []
        for player in players {
            if player.id != curLeague.creatorUID {
                if datasource[player.realName] != nil { // If multiple people have the same real name dont want it autofinishing
                    datasource[player.realName] = nil
                    duplicates.append(player.realName)
                } else if !duplicates.contains(player.realName) {
                    datasource[player.displayName] = player.displayName
                    datasource[player.realName] = player.displayName
    //                datasource[player.phoneNumber] = player.displayName
                }
            }
        }
        return datasource
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 16) {
            
            HStack {
                Text("Username")
                AutoCompleteTextFieldSwiftUI(text: $displayName, placeholder: "Player to delete", datasource: datasource, isResponder: $isResponder, nextResponder: .constant(nil))
            }
            
            if curLeague.players[curLeague.displayNameToUserID[displayName] ?? ""] != nil {
                Text("Real name: \(curLeague.players[curLeague.displayNameToUserID[displayName] ?? ""]!.realName)")
                
                Toggle(isOn: $removePlayerGames.onUpdate {
                    self.removePlayerGamesAlert = self.removePlayerGames
                    if self.removePlayerGames == false {
                        self.removePlayerInputGames = false
                    }
                }) {
                    Text("Remove \(displayName)'s profile")
                }.alert(isPresented: $removePlayerGamesAlert, content: {
                    Alert(title: Text("Are you sure you want this?"), message: Text("This will completely remove the player from the league and all of their games"))
                })
                
                if(removePlayerGames) {
                
                    Toggle(isOn: $removePlayerInputGames.onUpdate {
                        self.removePlayerInputGamesAlert = self.removePlayerInputGames
                    }) {
                        Text("Remove games input by \(displayName)")
                    }.alert(isPresented: $removePlayerInputGamesAlert, content: {
                        Alert(title: Text("Are you sure you want this?"), message: Text("You may want to check the games this player entered"))
                    })
                }
                
                Button(action: {
                    MyAlerts().showTextInputPrompt(placeholder: "", title: "Enter yes to remove", message: "", keyboardType: .default, callback: { userPressEnter, input  in
                        if userPressEnter {
                            if input.lowercased() == "yes" {
                                self.deletePlayer()
                            }
                        }
                    })
                }) {
                    SpanningLabel(color: .red, content: "Remove")
                }.alert(isPresented: $showingAlert) {
                    Alert(title: Text(self.alertMessage), primaryButton: .destructive(Text("Yes")) {
                    }, secondaryButton: .cancel())
                }
            }
            
            Spacer().layoutPriority(1)
        
        }
        .navigationBarTitle("Remove Player")
        .padding(.all, 16)
    }
        
        
    func deletePlayer() {
        self.session.remove(player: curLeague.players[curLeague.displayNameToUserID[displayName]!]!, fromLeague: curLeague, shouldDeletePlayerGames: removePlayerGames, shouldDeleteInputGames: removePlayerInputGames, completion: { error in
            if let error = error {
                print(error.localizedDescription)
                self.alertMessage = error.localizedDescription
            } else {
                self.mode.wrappedValue.dismiss()
            }
        })
        
    }
}

extension Binding {
    
    /// When the `Binding`'s `wrappedValue` changes, the given closure is executed.
    /// - Parameter closure: Chunk of code to execute whenever the value changes.
    /// - Returns: New `Binding`.
    func onUpdate(_ closure: @escaping () -> Void) -> Binding<Value> {
        Binding(get: {
            self.wrappedValue
        }, set: { newValue in
            self.wrappedValue = newValue
            closure()
        })
    }
}
