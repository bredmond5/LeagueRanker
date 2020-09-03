//
//  UnblockPlayers.swift
//  ScoreSender
//
//  Created by Brice Redmond on 8/31/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct UnblockPlayers: View {
    let curLeague: League
    
    var body: some View {
        VStack {
            List {
                ForEach(Array(curLeague.blockedPlayers.keys), id: \.self) { key in
                    VStack {
                        Text(self.curLeague.blockedPlayers[key]![0])
                        Text(self.curLeague.blockedPlayers[key]![1])
                        Text(self.curLeague.blockedPlayers[key]![2])
                    }
               }
           }
        }.navigationBarTitle("Blocked Players")
    }
    
}
