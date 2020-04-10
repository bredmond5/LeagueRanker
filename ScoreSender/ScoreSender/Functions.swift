//
//  Functions.swift
//  ScoreSender
//
//  Created by Brice Redmond on 4/9/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation
import SwiftUI

func checkValidGame(l: [String]) -> Game? {
    if(l.count != Set(l).count)  {
        return nil
    }
    
    for s in l {
        if s == ""  {
            return nil
        }
    }
    
    return Game(players: [l[0], l[1], l[2], l[3]], scores: [l[4], l[5]])
}
