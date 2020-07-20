//
//  TruncatedGaussianCorrectionFunctions.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 7/8/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

internal class TruncatedGaussianCorrectionFunctions {
    public static func VExceedsMargin(teamPerformanceDifference: Double, drawMargin: Double, c: Double = 1) -> Double {
        
        let tpDiff = teamPerformanceDifference / c
        let dm = drawMargin / c
        
        let denominator = GaussianDistribution.CumulativeTo(tpDiff - dm)
        
        if denominator < 2.222758749e-162 {
            return tpDiff + dm
        }
        
        return GaussianDistribution.At(tpDiff - dm)/denominator
        
    }
    
    public static func WExceedsMargin(teamPerformanceDifference: Double, drawMargin: Double, c: Double = 1) -> Double {
        let tpDiff = teamPerformanceDifference / c
        let dm = drawMargin / c
        
        let denominator = GaussianDistribution.CumulativeTo(tpDiff - dm)
        
        if denominator < 2.222758749e-162 {
            if tpDiff < 0.0 {
                return 1.0
            }
            return 0.0
        }
        let vWin = VExceedsMargin(teamPerformanceDifference: tpDiff, drawMargin: dm)
        return vWin*(vWin + tpDiff - dm)
    }
    
    public static func VWithinMargin(teamPerformanceDifference: Double, drawMargin: Double, c: Double = 1) -> Double {
        let tpDiff = teamPerformanceDifference / c
        let dm = drawMargin / c

        let teamPerformanceAbsoluteValue = abs(tpDiff)
        let denominator = GaussianDistribution.CumulativeTo(dm - teamPerformanceAbsoluteValue) - GaussianDistribution.CumulativeTo(-dm - teamPerformanceAbsoluteValue)
        
        if denominator < 2.222758749e-162 {
            if tpDiff < 0.0 {
                return -tpDiff - dm
            }
            return -tpDiff + dm
        }
        
        let numerator = GaussianDistribution.At(-dm - teamPerformanceAbsoluteValue) - GaussianDistribution.At(dm - teamPerformanceAbsoluteValue)
        
        if tpDiff < 0.0 {
            return -numerator / denominator
        }
        return numerator / denominator
    }
    
    public static func WWithinMargin(teamPerformanceDifference: Double, drawMargin: Double, c: Double = 1) -> Double {
        let tpDiff = teamPerformanceDifference / c
        let dm = drawMargin / c
        
        let teamPerformanceAbsoluteValue = abs(tpDiff)
        let denominator = GaussianDistribution.CumulativeTo(dm - teamPerformanceAbsoluteValue) - GaussianDistribution.CumulativeTo(-dm - teamPerformanceAbsoluteValue)
        
        let vt = VWithinMargin(teamPerformanceDifference: teamPerformanceAbsoluteValue, drawMargin: dm)
        return vt*vt
            + ((dm - teamPerformanceAbsoluteValue)
            * GaussianDistribution.At(dm - teamPerformanceAbsoluteValue)
            - (-dm - teamPerformanceAbsoluteValue)
            * GaussianDistribution.At(-dm - teamPerformanceAbsoluteValue))/denominator
    }
}
