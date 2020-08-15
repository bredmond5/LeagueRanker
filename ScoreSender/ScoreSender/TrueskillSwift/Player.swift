//
//  Player.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 4/26/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

class Player<T: Hashable>: Hashable {
    
    public func hash(into hasher: inout Hasher) { //definite possible issue here, should test, maybe ids should be unique?
        hasher.combine(id)
    }
    
    static func == (lhs: Player<T>, rhs: Player<T>) -> Bool {
        return lhs.id == rhs.id
    }
        
    let id: T
    
    let partialPlayPercentage: Double
    let partialUpdatePercentage: Double

    init(id: T,  partialPlayPercentage: Double = 1.0, partialUpdatePercentage: Double = 1.0) {
        self.id = id
        self.partialPlayPercentage = partialPlayPercentage
        self.partialUpdatePercentage = partialUpdatePercentage
    }
    
    func getId() -> T {
        return id
    }
    
    func getPartialPlayPercentage() -> Double {
        return partialPlayPercentage
    }
    
    func getPartialUpdatePercentage() -> Double {
        return partialUpdatePercentage
    }
    
    func toString() -> String {
        return  "Player \(id). "// + rating.description
    }
}
