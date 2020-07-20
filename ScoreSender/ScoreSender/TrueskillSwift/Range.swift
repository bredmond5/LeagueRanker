//
//  Range.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 7/6/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

enum ArgumentOutOfRangeException: Error {
    case minLessMax
}

public protocol Range {
    associatedtype T: Range
    init()
    
    var Min: Int { get set }
    var Max: Int { get set }
    static var _Instance: T { get set }
    
    func Create(min: Int, max: Int) -> T
}

extension Range where T: Range {
    mutating func Range(min: Int, max: Int) throws {
        if min > max {
            throw ArgumentOutOfRangeException.minLessMax
        }
        
        Min = min
        Max = max
    }

    public static func Inclusive(min: Int, max: Int) -> T {
        return Self._Instance.Create(min: min, max: max) as! Self.T //what the hell is going on here?
    }
    
    public static func Exactly(value: Int) -> T {
        return Self._Instance.Create(min: value, max: value) as! Self.T
    }
    
    public static func AtLeast(minValue: Int) -> T {
        return Self._Instance.Create(min: minValue, max: Int.max) as! Self.T
    }
    
    public func IsInRange(value: Int) -> Bool {
        return (Min <= value) && (value <= Max)
    }
}
