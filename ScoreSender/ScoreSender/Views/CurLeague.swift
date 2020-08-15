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
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var myAlerts = MyAlerts()
    
    @State var curLeague: League
    
    var body: some View {
        VStack (alignment: .leading){
            
            Divider()
            if curLeague.players.count < 4 {
                Button(action: {
                    self.myAlerts.showMessagePrompt(title: "Error", message: "4 or more players are required to add a game", callback: {})
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .foregroundColor(.black)
                }
            }else{
                NavigationLink(destination:
                    GameForm(curLeague: self.curLeague, inputter: self.session.session!.phoneNumber!,  didAddGame: { g, newRatings in
                        self.session.uploadGame(curLeague: self.curLeague, game: g, newRatings: newRatings)

                        //force swift to reload the page
                        self.curLeague.rankPlayers()
                        let temp = self.curLeague
                        self.curLeague = League()
                        self.curLeague = temp
                    }).navigationBarTitle("Add Game")) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .foregroundColor(.black)
                }
            }
            Divider()
            
//            LeaguesScroller()
//
            
            List(curLeague.sortedPlayers) { player in
                NavigationLink(destination:
                    ShowGames(player: player, curLeague: self.curLeague, deleteGame: { game, player in
                        self.session.deleteGame(fromLeague: self.curLeague, game: game, fromPlayer: player)
                    }))
                {
                    PlayerRow(player: player)
                }
                
            }
            
            
        }
       // .navigationBarBackButtonHidden(true)
        .navigationBarItems(
//                leading: Button(action : {
//                    self.mode.wrappedValue.dismiss()
//                }){
//                    Image(systemName: "arrow.left")
//                    .resizable()
//                    .frame(width: 20, height: 20)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 8)
//                        .foregroundColor(.blue)
//                },
                
                trailing:
            NavigationLink(destination: SettingsFormLeague(curLeague: self.curLeague)) {
                Image(systemName: "text.justify")
                .resizable()
                .frame(width: 20, height: 20)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .foregroundColor(.blue)
            }
        )}
}
