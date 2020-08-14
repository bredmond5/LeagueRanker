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
    @ObservedObject var player: PlayerForm
    
    let curLeague: League
    var deleteGame: (Game, PlayerForm) -> ()

    var green = Color(.sRGB, red: 0.4, green: 1.0, blue: 0, opacity: 1.0)
    var red = Color(.sRGB, red: 1.0, green: 0.8, blue: 203/255, opacity: 1.0)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
            
            HStack {
                Text("Real Name: \(player.realName)")
                    .fontWeight(.heavy)
                    .font(.system(size: 16))
                .padding(.leading, 12)
                Spacer()
                Text("Record: \(player.wins)-\(player.losses)")
                .fontWeight(.heavy)
                .font(.system(size: 16))
                .padding(.trailing, 12)
            }
            
            HStack {
                NavigationLink(destination: OtherPlayerMeanChanges(dict: player.bestTeammates)) {
                    Text("See Best Partners")
                    .fontWeight(.heavy)
                        .font(.system(size: 16))
                    .padding(.leading, 12)
                }
                
                Spacer()
                
                NavigationLink(destination: OtherPlayerMeanChanges(dict: player.rivals)) {
                    Text("See Rivals")
                    .fontWeight(.heavy)
                        .font(.system(size: 16))
                    .padding(.leading, 12)
                }
            }
            
            List {
                Text("Games:")
                .fontWeight(.heavy)
                .font(.system(size: 24))
                .padding(.leading, 12)
                
                ForEach(player.playerGames, id: \.self) { game in
                    NavigationLink(destination: SingleGameView(game: game, player: self.player, canDelete: (self.getCanDelete(gameInputter: game.inputter ?? "")), deleteGame: { game, player in
                        self.deleteGame(game, player)
                    }, curLeague: self.curLeague)) {
                        GameRow(game: game, playerName: self.player.displayName, players: self.curLeague.players)
                    }
                    .frame(height: 60)
                    .listRowBackground(game.gameScore > 0 ? self.green : self.red)
//                    .overlay(
//                    RoundedRectangle(cornerRadius: 0)
//                        .strokeBorder(style: StrokeStyle(lineWidth: 2))
//                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 1)))
                }
            }
            
                
//                if self.canDelete {
//                    Button(action: {
//                            MyAlerts().showCancelOkMessage(title: "Are you sure you want to delete this game?", message: "There is no going back", callback: { userPressedOk in
//                                if userPressedOk {
//                                    self.deleteGame(game, self.player)
//                                }
//                            })
//
//                    }, label: {
//                        GameRow(game: game, playerName: self.player.displayName)
//
//                    }).listRowBackground(Color.red)
//                }else{
//                    GameRow(game: game, playerName: self.player.displayName)
//                }
//            }.edgesIgnoringSafeArea(.all)
        }.navigationBarTitle(Text("\(player.displayName)"))
    }
    
    func getCanDelete(gameInputter: String) -> Bool {
        let phoneNumber = self.session.session!.phoneNumber!
        return (phoneNumber == curLeague.creatorPhone || gameInputter == phoneNumber)
    }
}


struct GameRow: View {
    var game: Game
    var id: UUID
    
    var players: [String : PlayerForm]
    
    var playerName: String
    
    init(game: Game, playerName: String, players: [String: PlayerForm]) {
        self.game = game
        self.playerName = playerName
        self.players = players
        self.id = UUID()
    }
    
    @ViewBuilder
    var body: some View {
        GeometryReader { geometry in
            VStack {
                self.row
                    .frame(width: (geometry.size.width), height: geometry.size.height, alignment: .center)
            }
        }
    }
    
    
    var row: some View {
        VStack {
            HStack {
                
                VStack (alignment: .center, spacing: 5){
                    BoldTextToggle(isBold: self.playerName == players[game.team1[0]]?.displayName ?? game.team1[0], name: players[game.team1[0]]?.displayName ?? game.team1[0])
                    
                    BoldTextToggle(isBold: self.playerName == players[game.team1[1]]?.displayName ?? game.team1[1], name: players[game.team1[1]]?.displayName ?? game.team1[1])
                }
               
                Spacer()
                
                BoldTextToggle(isBold: game.team1.contains(self.playerName), name: game.scores[0])
                
                Text("-")
                    .font(.system(size: 12))
                
                BoldTextToggle(isBold: game.team2.contains(self.playerName), name: game.scores[1])
               
                Spacer()
                
                VStack (alignment: .center, spacing: 5){
                    BoldTextToggle(isBold: self.playerName == players[game.team2[0]]?.displayName ?? game.team2[0], name: players[game.team2[0]]?.displayName ?? game.team2[0])
                    
                    BoldTextToggle(isBold: self.playerName == players[game.team2[1]]?.displayName ?? game.team2[1], name: players[game.team2[1]]?.displayName ?? game.team2[1])
                    
                }
                Text(String(format: "%.02f", game.gameScore))
                .font(.system(size: 12))
                .fontWeight(.bold)
                    .padding(.all, 10)
                    
            }
        }
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



