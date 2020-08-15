//
//  SingleGameView.swift
//  ScoreSender
//
//  Created by Brice Redmond on 8/11/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation
import SwiftUI

struct SingleGameView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var game: Game
    
    var player: PlayerForm
    var canDelete: Bool
    
    var width: CGFloat = 60.0
    
    var deleteGame: (Game, PlayerForm) -> ()
    
    var curLeague: League
    
    @State var showingAlert = false
        
    var body: some View {
        VStack (alignment: .leading, spacing: 16) {
            
            Group {
                if curLeague.players[game.inputter]?.displayName != nil{
                    Text("Input by \(curLeague.players[game.inputter]!.displayName) (\( curLeague.players[game.inputter]!.realName)) on \(Date(timeIntervalSinceReferenceDate: TimeInterval(Int(game.date)! / 1000)).toString())").fixedSize(horizontal: false, vertical: true).lineLimit(nil)
                } else {
                    Text("Date: \(Date(timeIntervalSinceReferenceDate: TimeInterval(Int(game.date)! / 1000)).toString())")

                }
                Text("Player change: \(game.gameScore)")
                .fontWeight(.heavy)
                Text("Sigma change: \(game.sigmaChange)")
                .fontWeight(.heavy)
                Divider()
                
                Text("Team 1:")
                    .fontWeight(.heavy)
                    .font(.system(size: 24))
                            
                Text("Player 1: \(curLeague.players[game.team1[0]]?.displayName ?? game.team1[0]) \(addExtra(forPhoneNumber: curLeague.players[game.team1[0]]?.displayName ?? game.team1[0]))")
                    .fontWeight(.heavy)

                Text("Player 2: \(curLeague.players[game.team1[1]]?.displayName ?? game.team1[1]) \(addExtra(forPhoneNumber: curLeague.players[game.team1[1]]?.displayName ?? game.team1[1]))")
                    .fontWeight(.heavy)
                
                Divider()
                Text("Score: \(game.scores[0]) - \(game.scores[1])")
                    .fontWeight(.heavy)
                    .font(.system(size: 24))
            }
            
            
            Group {
                Divider()

                Text("Team 2:")
                    .fontWeight(.heavy)
                    .font(.system(size: 24))

                Text("Player 3: \(curLeague.players[game.team2[0]]?.displayName ?? game.team2[0]) \(addExtra(forPhoneNumber: curLeague.players[game.team2[0]]?.displayName ?? game.team2[0]))")
                    .fontWeight(.heavy)
    //
                Text("Player 4: \(curLeague.players[game.team2[1]]?.displayName ?? game.team2[1]) \(addExtra(forPhoneNumber: curLeague.players[game.team2[1]]?.displayName ?? game.team2[1]))")
                    .fontWeight(.heavy)

                Divider()
                    
                if canDelete {
                    
                    Button(action: {
                        self.showingAlert.toggle()
                    })
                    {
                        SpanningLabel(color: .red, content: "Delete Game")
                    }.alert(isPresented: $showingAlert) {
                            Alert(title: Text("Are you sure you want to delete this game?"), message: Text("There is no going back"), primaryButton: .destructive(Text("Ok")) {
                                self.deleteGame(self.game, self.player)
                                self.mode.wrappedValue.dismiss()
                        }, secondaryButton: .cancel())
                    }
                }
                Spacer()
            }
        }.navigationBarTitle("\(self.player.displayName)'s \(game.gameScore > 0 ? "win" : "loss")")
            .padding(.all, 16)
    }
    
    func addExtra(forPhoneNumber phoneNumber: String) -> String {
//        if let realName = curLeague.getRealName(fromDisplayName: displayName) {
//            return realName == displayName ? "" : "(\(realName))"
//        } else {
//            return ""
//        }
        
        if let player = curLeague.players[phoneNumber] {
            return player.realName == player.displayName ? "" : "(\(player.realName))"
        } else {
            return ""
        }
    }
}

extension Date {

    func toString() -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        let str = dateFormatter.string(from: self)

        return str
    }
}
