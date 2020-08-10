//
//  GameInfo.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 4/26/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

public class GameInfo {
    
    var drawProbability: Double
    var dynamicsFactor: Double
    var initialStandardDeviation: Double
    var initialMean: Double
    var beta: Double
    
    init(initialMean: Double = 25.0, initialStandardDeviation: Double = 25.0/3, beta: Double = 25.0/6.0, dynamicsFactor: Double = 25.0/300.0, drawProbability: Double = 0.1) {
        self.initialMean = initialMean
        self.drawProbability = drawProbability
        self.dynamicsFactor = dynamicsFactor
        self.initialStandardDeviation = initialStandardDeviation
        self.beta = beta
        
    }
    
    public var DefaultRating: Rating {
        return Rating(mean: initialMean, standardDeviation: initialStandardDeviation)
    }
    
    public static var DefaultGameInfo: GameInfo {
        return GameInfo()
    }
    
    
}
