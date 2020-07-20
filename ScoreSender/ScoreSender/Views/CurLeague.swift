//
//  CurLeague.swift
//  ScoreSender
//
//  Created by Brice Redmond on 5/14/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct CurLeague: View {
         
    @EnvironmentObject var session: FirebaseSession
    
    var myAlerts = MyAlerts()
    
    var body: some View {
        VStack {
            Divider()
            LeaguesScroller()
            Divider()
            
            List(self.session.curLeague.returnPlayers().sorted()) { player in
                NavigationLink(destination: ShowGames(player: player).navigationBarTitle(player.displayName + "'s games"))
                {
                    PlayerRow(player: player)
                }
            }
            
            
        }.navigationBarTitle(self.session.curLeague.name)
            .navigationBarItems(
                leading: NavigationLink(destination: SettingsForm(currentUsername: session.session?.displayName ?? "user1234").navigationBarTitle("Settings")) {
                        Text("Settings")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.gray)
                        .cornerRadius(4)
                },
                
                trailing: VStack {
                    if self.session.leagues.isEmpty {
                        Button(action: {
                            self.myAlerts.showMessagePrompt(title: "Error", message: "User needs to be in a league to add a game", callback: {})
                        }) {
                            Text("Add Game")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.green)
                            .cornerRadius(4)
                        }
                        
                    } else if self.session.curLeague.players.count < 4 {
                        Button(action: {
                            self.myAlerts.showMessagePrompt(title: "Error", message: "4 or more players are required to add a game", callback: {})
                        }) {
                            Text("Add Game")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.green)
                            .cornerRadius(4)
                        }
                    }else{
                        NavigationLink(destination:
                            GameForm(didAddGame: { g, newRatings in
                                self.session.uploadGame(game: g, newRatings: newRatings)
                            }).navigationBarTitle("Add Game")) {
                            Text("Add Game")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.green)
                            .cornerRadius(4)
                        }
                    }
            }
        )}
}
