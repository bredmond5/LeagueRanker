//
//  PlayersRange.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 7/6/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

public class PlayersRange: Range {
    public static var _Instance: PlayersRange = PlayersRange()
    
    public typealias T = PlayersRange
    public var Min: Int
    public var Max: Int
    
    required public init() {
        self.Min = Int.min
        self.Max = Int.max
    }
    
    private init(_ min: Int, _ max: Int) {
        Min = min
        Max = max
    }
    
    public func Create(min: Int, max: Int) -> T {
        return PlayersRange(min, max)
    }
}
