//
//  LeagueRow.swift
//  ScoreSender
//
//  Created by Brice Redmond on 7/30/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct LeagueRow: View {
    @ObservedObject var league: League
    
    var body: some View {
        HStack {
            Image(uiImage: league.leagueImage ?? UIImage())
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 60)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2))
                        .foregroundColor(Color.black))
                .cornerRadius(60)
            
            Text("\(league.name)")
                    .fontWeight(.bold)
            
            Spacer()
//            Button(action: {
//                print(self.player.displayName)
//            }) {
           
            
            Text("See League")
                .foregroundColor(.white)
                .fontWeight(.bold)
                .padding(.all, 12)
                .background(Color.blue)
                .cornerRadius(3)
                //}
            
        }.padding(.vertical, 8)
    }
}
