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

    var game: PlayerGame
    
    var player: PlayerForm
    var canDelete: Bool
    
    var width: CGFloat = 60.0
    
    var deleteGame: (Game, PlayerForm) -> ()
    
    var curLeague: League
    
    @State var showingAlert = false
    let shouldShowScore: Bool
    
    var green = Color(.sRGB, red: 0.4, green: 1.0, blue: 0, opacity: 1.0)
    var red = Color(.sRGB, red: 1.0, green: 0.8, blue: 203/255, opacity: 1.0)
    
    init(game: PlayerGame, player: PlayerForm, canDelete: Bool, shouldShowScore: Bool, deleteGame: @escaping (Game, PlayerForm) -> (), curLeague: League) {
        self.game = game
        self.player = player
        self.canDelete = canDelete
        self.deleteGame = deleteGame
        self.curLeague = curLeague
        self.shouldShowScore = shouldShowScore
           
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: game.gameScore > 0 ? UIColor.red : UIColor.green]
    }
        
    var body: some View {
//        NavigationView {
        VStack (alignment: .leading, spacing: 16) {
            
            Group {
                if curLeague.players[game.inputter]?.displayName != nil{
                    Text("Input by \(curLeague.players[game.inputter]!.displayName) \(addExtra(forUID: game.inputter))on \(Date(timeIntervalSinceReferenceDate: TimeInterval(Int(game.date)! / 1000)).toString())").fixedSize(horizontal: false, vertical: true).lineLimit(nil)
                } else {
                    Text("Date: \(Date(timeIntervalSinceReferenceDate: TimeInterval(Int(game.date)! / 1000)).toString())")

                }
                
                if shouldShowScore {
                
                    Text("Player score change: \(game.gameScore)")
                    .fontWeight(.heavy)
                    Text("Player sigma change: \(game.sigmaChange)")
                    .fontWeight(.heavy)
                    Divider()
                }
            
            
                Text("Score: \(game.scores[0])")
                .fontWeight(.heavy)
                .font(.system(size: 24))
//                Text("Player 1: \(curLeague.players[game.team1[0]]?.displayName ?? game.team1[0]) \(addExtra(forPhoneNumber: curLeague.players[game.team1[0]]?.phoneNumber ?? game.team1[0]))")
//                    .fontWeight(.heavy)
                if curLeague.players[game.team1[0]] != nil {
                    SingleGamePlayerRow(player: curLeague.players[game.team1[0]]!)
                } else {
                    Text(game.team1[0])
                    .fontWeight(.heavy)

                }
                
                if curLeague.players[game.team1[1]] != nil {
                    SingleGamePlayerRow(player: curLeague.players[game.team1[1]]!)
                } else {
                    Text(game.team1[1])
                    .fontWeight(.heavy)

                }
            }
                

            Group {
                Divider()
                Text("Score: \(game.scores[1])")
                    .fontWeight(.heavy)
                        .font(.system(size: 24))

                if curLeague.players[game.team2[0]] != nil {
                    SingleGamePlayerRow(player: curLeague.players[game.team2[0]]!)
                } else {
                    Text(game.team2[0])
                    .fontWeight(.heavy)

                }
                
                if curLeague.players[game.team2[1]] != nil {
                    SingleGamePlayerRow(player: curLeague.players[game.team2[1]]!)
                } else {
                    Text(game.team2[1])
                    .fontWeight(.heavy)

                }
                    
                Spacer()
            }
        }.navigationBarTitle("\(self.player.displayName)'s \(game.gameScore > 0 ? "win" : "loss")")
            .padding(.all, 16)
            .navigationBarItems(
//                leading:
//                Button(action: {
//                    self.mode.wrappedValue.dismiss()
//                }) {
//                    Image(systemName: "arrow.left")
//                    .resizable()
//                    .frame(width: 20, height: 20)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 8)
//                    .foregroundColor(.blue)
//                }
                trailing:
              
              Button(action: {
                  self.showingAlert.toggle()
              })
              {
               //if self.canDelete {
                  Image(systemName: "trash")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .foregroundColor(.blue)
                //}
              }.alert(isPresented: $showingAlert) {
                      Alert(title: Text("Are you sure you want to delete this game?"), message: Text("There is no going back"), primaryButton: .destructive(Text("Ok")) {
                          self.deleteGame(self.game, self.player)
                          self.mode.wrappedValue.dismiss()
                  }, secondaryButton: .cancel())
              }
          )
//        }.hiddenNavigationBarStyle()
    }
    
    func addExtra(forUID uid: String) -> String {
//        if let realName = curLeague.getRealName(fromDisplayName: displayName) {
//            return realName == displayName ? "" : "(\(realName))"
//        } else {
//            return ""
//        }
        
        if let player = curLeague.players[uid] {
            return player.realName == player.displayName ? "" : "(\(player.realName)) "
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

struct HiddenNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        content
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
}

extension View {
    func hiddenNavigationBarStyle() -> some View {
        modifier( HiddenNavigationBar() )
    }
}
