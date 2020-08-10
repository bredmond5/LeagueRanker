//
//  ShowGames.swift
//  ScoreSender
//
//  Created by Brice Redmond on 6/2/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct ShowGames: View {
    @EnvironmentObject var session: FirebaseSession
    var player: PlayerForm
    
    let canDelete: Bool
    var deleteGame: (Game, PlayerForm) -> ()
    
    var body: some View {
        VStack {
            List (player.playerGames) { game in
               // if self.session.curLeague.creatorPhone == self.session.session?.phoneNumber {
                if self.canDelete {
                    Button(action: {
                            MyAlerts().showCancelOkMessage(title: "Are you sure you want to delete this game?", message: "There is no going back", callback: { userPressedOk in
                                if userPressedOk {
                                    self.player.playerGames.removeAll(where: {$0.id == game.id})
                                    self.deleteGame(game, self.player)
                                }
                            })
                            
                    }, label: {
                        GameRow(game: game, playerName: self.player.displayName)
                    })
                }else{
                    GameRow(game: game, playerName: self.player.displayName)
                }
            }
        }
    }
}

struct GameRow: View {
    var game: Game
    var id: UUID
    
    var playerName: String
    
    init(game: Game, playerName: String) {
        self.game = game
        self.playerName = playerName
        self.id = UUID()
    }
    
    @ViewBuilder
    var body: some View {
        if(game.gameScore > 0) {
            ZStack {
                row
            }.background(Color(.sRGB, red: 0.4, green: 1.0, blue: 0, opacity: 1.0))
        }else{
            ZStack {
                row
            }.background(Color(.sRGBLinear, red: 1, green: 135/255, blue: 132/255, opacity: 1.0))
        }
    }
    
    var row: some View {
        VStack {
            HStack {
                
                VStack (alignment: .center, spacing: 5){
                    BoldTextToggle(isBold: self.playerName == game.team1[0], name: game.team1[0])
                    
                    BoldTextToggle(isBold: self.playerName == game.team1[1], name: game.team1[1])
                }
               
                Spacer()
                
                BoldTextToggle(isBold: game.team1.contains(self.playerName), name: game.scores[0])
                
                Text("-")
                    .font(.system(size: 12))
                
                BoldTextToggle(isBold: game.team2.contains(self.playerName), name: game.scores[1])
               
                Spacer()
                VStack (alignment: .center, spacing: 5){
                    BoldTextToggle(isBold: self.playerName == game.team2[0], name: game.team2[0])
                    
                    BoldTextToggle(isBold: self.playerName == game.team2[1], name: game.team2[1])
                    
                }
                Text(String(format: "%.02f", game.gameScore))
                .font(.system(size: 12))
                .fontWeight(.bold)
                    .padding(.all, 10)
                    
            }
        }.padding(.all, 10)
    }
    
}

struct BoldTextToggle: View {
    var isBold: Bool
    var name: String
    
    var body: some View {
        VStack {
            if isBold {
                Text(String(name))
                .font(.system(size: 12))
                .fontWeight(.bold)
            }else{
                Text(String(name))
                .font(.system(size: 12))
                
            }
        }
    }
}



