//
//  LeaguesScroller.swift
//  ScoreSender
//
//  Created by Brice Redmond on 5/14/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

enum ActiveSheet {
   case first, second, third
}

struct LeaguesScroller : View {
    @EnvironmentObject var session: FirebaseSession

    @State var colors: [Color] = [.red, .yellow, .green, .blue, .purple]
    @State var showingSheet = false
    @State var isPresentingModal = false
    
    @State private var activeSheet: ActiveSheet = .first
    
    var count = 0
    
     var body: some View {
        
        ScrollView(.horizontal) {
            HStack(spacing: 5) {
                Button(action: {
                    self.showingSheet.toggle()
                }, label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                    
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
                        NewLeague(isPresented: self.$isPresentingModal, user: self.session.session!, didAddLeague: { leagueName, leagueImage, displayName, playerImage in
                            self.session.uploadLeague(leagueName: leagueName, leagueImage: leagueImage, displayName: displayName, playerImage: playerImage)

                        }, userLeagueNames: self.session.getUserLeagueNames())
                    }else if self.activeSheet == .second {
                        JoinLeague(isPresented: self.$isPresentingModal, user: self.session.session!, didAddLeague : { leagueID, leagueName, username, creatorPhoneNumber, image  in
                            self.session.joinLeague(leagueID: leagueID, leagueName: leagueName, displayName: username, phoneNumber: creatorPhoneNumber, image: image)
                            //self.session.addLeague(name: n, image: i)
//                            self.session.uploadLeague(league: League(users: [self.session.session!], games: nil, name: n, image: i))
                        })
                    } else {
                        
                    }
                }).buttonStyle(PlainButtonStyle())
            
                ForEach(self.session.leagues) { league in
                    self.buildView(l: league)
                }
            }
        }
    
    }
    
    func buildView(l: League) -> AnyView? {
        if l.id != session.curLeague.id {
            return AnyView(Button(action: {
                self.session.changeCurLeague(league: l)
            }, label: {
                Text(l.name)
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                  .background(Color.red)
                .cornerRadius(4)
            }))
        }else{
             return AnyView(Button(action: {
                   self.session.changeCurLeague(league: l)
               }, label: {
                   Text(l.name)
                   .foregroundColor(.white)
                   .padding(.vertical, 8)
                   .padding(.horizontal, 12)
                     .background(Color.red)
                   .cornerRadius(4)
                }).disabled(true))
        }
    }
}
