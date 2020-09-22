//
//  LeagueGamesActivity.swift
//  ScoreSender
//
//  Created by Brice Redmond on 8/31/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct LeagueGamesActivity: View {
    
    let games: [Game]
    
    let players: [String: PlayerForm]
    
    var body: some View {
        VStack {
            List {
                ForEach(games, id: \.self) { game in
                    LeagueGameRow(game: game, players: self.players)
                }
            }
        }.navigationBarTitle("League Games")
    }
}

struct LeagueGameRow: View {
    let game: Game
    let players: [String: PlayerForm]
    
    var body: some View {
        HStack {
            VStack (alignment: .center, spacing: 5) {
                Text(self.players[game.team1[0]]?.displayName ?? "")
                    .font(.system(size: 12))
                    .fontWeight(.bold)
                Text(self.players[game.team1[1]]?.displayName ?? "")
                    .font(.system(size: 12))
                    .fontWeight(.bold)
            }

            Spacer()

            Text("\(game.scores[0])")
                .font(.system(size: 12))
                .fontWeight(.bold)

             Text("-")
                 .font(.system(size: 12))

            Text("\(game.scores[1])")
                .font(.system(size: 12))
                .fontWeight(.bold)

             Spacer()

             VStack (alignment: .center, spacing: 5) {
                Text(self.players[game.team2[0]]?.displayName ?? "")
                    .font(.system(size: 12))
                    .fontWeight(.bold)
                Text(self.players[game.team2[1]]?.displayName ?? "")
                    .font(.system(size: 12))
                    .fontWeight(.bold)
            }
         }
    }
}
