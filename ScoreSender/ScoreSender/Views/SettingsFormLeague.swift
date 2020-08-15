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
    
    let curLeague: League
    @State private var keyboardHeight: CGFloat = 0
    
    @State var showingAlert = false

    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Creator phone number: \(String(curLeague.creatorPhone[curLeague.creatorPhone.index(curLeague.creatorPhone.startIndex, offsetBy: 2)...]))")
                .fontWeight(.heavy)
                .font(.system(size: 16))
                
            NavigationLink(destination: ChangeProfileLeague(curLeague: self.curLeague, player: self.curLeague.players[self.session.session!.phoneNumber!]!)) {
                SpanningLabel(color: Color.blue, content: "Edit Profile")
            }
            
            Button(action: redoLeague) {
                SpanningLabel(color: .red, content: "Switch to phone Numbers")
            }
            
            
            if curLeague.creatorPhone == session.session!.phoneNumber! {
                
                Button(action: {
                    MyAlerts().showTextInputPrompt(placeholder: "", title: "Delete league", message: "Enter the name of the league to delete it", keyboardType: .default, callback: { userPressEnter, name  in
                        if userPressEnter && name == self.curLeague.name {
                            print("Deleting!")
                        }
                    })
                }) {
                    SpanningLabel(color: .red, content: "Delete League")
                }
                Button(action: { self.showingAlert.toggle() }) {
                    SpanningLabel(color: .red, content: "Recalculate Rankings")
                }.alert(isPresented: $showingAlert) {
                    Alert(title: Text("Recalculate Rankings"), message: Text("This button should be used if you suspect that the rankings may have been corrupted"), primaryButton: .default(Text("Go")) {
                        self.resetRankings()
                    }, secondaryButton: .cancel())
                }
            } else {
                Button(action: {
                   MyAlerts().showTextInputPrompt(placeholder: "", title: "Leave league", message: "Enter the name of the league to leave it", keyboardType: .default, callback: { userPressEnter, name  in
                       if userPressEnter && name == self.curLeague.name {
                           print("Leaving!")
                       }
                   })
               }) {
                   SpanningLabel(color: .red, content: "Leave League")
               }
            }
            Spacer()
            }
            .padding(.all, 12)
            .navigationBarTitle("Settings")
            .onReceive(Publishers.keyboardHeight, perform: {self.keyboardHeight = $0})
    }
    
    func resetRankings() {
        session.recalculateRankings(forLeague: curLeague)
    }
    
    func redoLeague() {
        session.redoLeague(forLeague: curLeague)
    }
}

