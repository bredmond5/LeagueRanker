//
//  TeamsRange.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 7/6/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

public class TeamsRange: Range {    
   public typealias T = TeamsRange
   public var Min: Int
   public var Max: Int
   public static var _Instance: T = TeamsRange()
   
   required public init() {
       self.Min = Int.min
       self.Max = Int.max
   }
   
   private init(_ min: Int, _ max: Int) {
       Min = min
       Max = max
   }
   
   public func Create(min: Int, max: Int) -> T {
       return TeamsRange(min, max)
   }
}
