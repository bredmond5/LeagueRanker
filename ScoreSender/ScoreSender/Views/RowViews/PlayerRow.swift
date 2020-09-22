//
//  PlayerRow.swift
//  ScoreSender
//
//  Created by Brice Redmond on 5/11/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct PlayerRow: View {
    
    @ObservedObject var player: PlayerForm
    var id: UUID
    
    init(player: PlayerForm) {
        self.player = player
        id = UUID()
    }
    
    var body: some View {
        HStack {
            Text(String(player.rank))
                .font(.system(size: 20))
            Image(uiImage: player.image ?? UIImage())
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 60)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2))
                        .foregroundColor(Color.black))
                .cornerRadius(60)
            
            VStack (alignment: .leading) {
                Text("\(player.displayName)")
                    .fontWeight(.bold)
                if player.enoughGames() {
                    Text(String(format: "%.02f", player.rating.Mean))
                    .fontWeight(.light)
                } else {
                    Text("\(player.numPlacementsRequired - player.wins - player.losses) games left")
                }
            }.layoutPriority(1)
            
            Spacer()
//            Button(action: {
//                print(self.player.displayName)
//            }) {
            
            Text("See Stats")
                .foregroundColor(.white)
                .fontWeight(.bold)
                .padding(.all, 12)
                .background(Color.blue)
                .cornerRadius(3)
            
        }.padding(.vertical, 8)
    }
}
