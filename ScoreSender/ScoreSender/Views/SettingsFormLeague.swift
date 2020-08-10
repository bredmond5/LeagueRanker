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

    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Username: " + curLeague.players[session.session!.phoneNumber!]!.displayName)
            NavigationLink(destination: Text("Change username")) {
                Text("Change Username")
            }
            
            Text("Leave League")
            NavigationLink(destination: Text("Change username")) {
                Text("Change Username")
            }
            
            if curLeague.creatorPhone == session.session!.phoneNumber! {
                Text("Delete league")
            }
        

            }
            .padding(.all, 12)
            .navigationBarTitle("Settings")
            .onReceive(Publishers.keyboardHeight, perform: {self.keyboardHeight = $0})
    }
}

