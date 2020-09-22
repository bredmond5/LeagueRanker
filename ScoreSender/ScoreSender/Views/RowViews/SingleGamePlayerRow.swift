//
//  SingleGamePlayerRow.swift
//  ScoreSender
//
//  Created by Brice Redmond on 8/17/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct SingleGamePlayerRow: View {
    var player: PlayerForm

    var body: some View {
        HStack {
            Image(uiImage: player.image ?? UIImage())
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2))
                        .foregroundColor(Color.black))
                .cornerRadius(40)
            
            VStack (alignment: .leading) {
                Text("\(player.displayName)")
                    .fontWeight(.bold)
//                Text(String(format: "%.02f", player.rating.Mean))
//                    .fontWeight(.light)
                if player.realName != player.displayName {
                    Text("\(player.realName)")
                    .fontWeight(.light)
                }
                
            }.layoutPriority(1)
            
 //           Spacer()
            
//            Text("See Stats")
//            .foregroundColor(.white)
//            .fontWeight(.bold)
//            .padding(.all, 12)
//            .background(Color.blue)
//            .cornerRadius(3)
            
//            Button(action: {
//                print(self.player.displayName)
//            }) {
            //}
        }
    }
}

