//
//  OtherPlayerMeanChanges.swift
//  ScoreSender
//
//  Created by Brice Redmond on 8/12/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation
import SwiftUI

struct OtherPlayerMeanChanges: View {
    
    var dict: [String: Double]
    
    var body: some View {
        ForEach(dict.sorted(by: { $0.1 < $1.1 }), id: \.key) { key, value in
            Text("\(key): \(value)")
        }
    }
}
