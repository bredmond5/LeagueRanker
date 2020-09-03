//
//  AddLeague.swift
//  ScoreSender
//
//  Created by Brice Redmond on 7/30/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct AddLeague: View {
    @EnvironmentObject var session: FirebaseSession

    @State var colors: [Color] = [.red, .yellow, .green, .blue, .purple]
    @State var showingSheet = false
    @State var isPresentingModal = false

    @State private var activeSheet: ActiveSheet = .first

    var count = 0

     var body: some View {
        HStack(spacing: 5) {
            Button(action: {
                self.showingSheet.toggle()
            }, label: {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .foregroundColor(.blue)
                
            }).actionSheet(isPresented: $showingSheet) {
                ActionSheet(title: Text("New League"), message: Text("Join a league or create a new one"), buttons: [ .default(Text("Create New League")) {
                        self.isPresentingModal.toggle()
                        self.activeSheet = .first
                    },
                    .default(Text("Join Existing League")) {
                        self.isPresentingModal.toggle()
                        self.activeSheet = .second
                        
                    },
    //                        .default(Text("Invite to League")) {
    //                               self.isPresentingModal.toggle()
    //                               self.activeSheet = .third
    //
    //                        },
                    .cancel()
                ])
            }.sheet(isPresented: $isPresentingModal, content: {
                if self.activeSheet == .first {
                    NewLeague(isPresented: self.$isPresentingModal).environmentObject(self.session)
                }else if self.activeSheet == .second {
                    JoinLeague(isPresented: self.$isPresentingModal).environmentObject(self.session)
                } else {
                    
                }
            }).buttonStyle(PlainButtonStyle())
        }
    }
}
