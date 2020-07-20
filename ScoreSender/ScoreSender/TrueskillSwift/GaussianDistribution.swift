//
//  GaussianDistribution.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 7/7/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

class GaussianDistribution {
    
    public private(set) var Mean: Double
    public private(set) var StandardDeviation: Double
    public private(set) var Precision: Double
    public private(set) var PrecisionMean: Double
    var Variance: Double
    
    private init(copying gd: GaussianDistribution) {
        Mean = gd.Mean
        StandardDeviation = gd.StandardDeviation
        Variance = gd.Variance
        Precision = gd.Precision
        PrecisionMean = gd.PrecisionMean
    }
    
    private init(precisionMean: Double, precision: Double) {
        Precision = precision
        PrecisionMean = precisionMean
        Variance = 1.0/precision
        StandardDeviation = Variance.squareRoot()
        Mean = PrecisionMean/Precision
    }
    
    public init(mean: Double, standardDeviation: Double) {
        Mean = mean
        StandardDeviation = standardDeviation
        Variance = standardDeviation * standardDeviation
        Precision = 1/Variance
        PrecisionMean = Precision*Mean
    }
    
    public var NormalizationConstant: Double {
        return 1.0/(2*Double.pi).squareRoot()*StandardDeviation
    }
    
    public func Clone() -> GaussianDistribution {
        let result = GaussianDistribution(copying: self)
        return result
    }
    
    public static func FromPrecisionMean(precisionMean: Double, precision: Double) -> GaussianDistribution {
        let gaussianDistribution = GaussianDistribution(precisionMean: precisionMean, precision: precision)
        return gaussianDistribution
    }
    
    // Although we could use equations from // For details, see http://www.tina-vision.net/tina-knoppix/tina-memo/2003-003.pdf
    // for multiplication, the precision mean ones are easier to write :)
    public static func *(lhs: GaussianDistribution, rhs: GaussianDistribution) -> GaussianDistribution {
        return FromPrecisionMean(precisionMean: lhs.PrecisionMean + rhs.PrecisionMean, precision: lhs.Precision + rhs.Precision)
    }

    public static func AbsoluteDifference(lhs: GaussianDistribution, rhs: GaussianDistribution) -> Double {
        return max(abs(lhs.PrecisionMean - rhs.PrecisionMean), sqrt(abs(lhs.Precision - rhs.Precision)))
    }
    
    public static func -(lhs: GaussianDistribution, rhs: GaussianDistribution) -> Double {
        return AbsoluteDifference(lhs: lhs, rhs: rhs)
    }
    
    public static func LogProductNormalization(lhs: GaussianDistribution, rhs: GaussianDistribution) -> Double {
        if lhs.Precision == 0 || rhs.Precision == 0 {
            return 0
        }
        
        let varianceSum = lhs.Variance + rhs.Variance
        let meanDifference = lhs.Mean - rhs.Mean
        let logSqrt2Pi = log(sqrt(2*Double.pi))
        
        return -logSqrt2Pi - (log(varianceSum) / 2) - (Square(meanDifference)/(2*varianceSum))
    }
    
    public static func /(numerator: GaussianDistribution, denominator: GaussianDistribution) -> GaussianDistribution {
        return FromPrecisionMean(precisionMean: numerator.PrecisionMean - denominator.PrecisionMean, precision: numerator.Precision - denominator.Precision)
    }
    
    public static func LogRatioNormalization(numerator: GaussianDistribution, denominator: GaussianDistribution) -> Double {
        if numerator.Precision == 0 || denominator.Precision == 0 {
            return 0
        }
        
        let varianceDifference = denominator.Variance - numerator.Variance
        let meanDifference = numerator.Mean - denominator.Mean
        let logSqrt2Pi = log(sqrt(2*Double.pi))
        
        return log(denominator.Variance) + logSqrt2Pi - log(varianceDifference)/2 + Square(meanDifference)/(2*varianceDifference)
    }
    
    private static func Square(_ x: Double) -> Double {
        return x*x
    }
    
    public static func At(_ x: Double, _ mean: Double = 0, standardDeviation: Double = 1) -> Double {
        // See http://mathworld.wolfram.com/NormalDistribution.html
        //                1              -(x-mean)^2 / (2*stdDev^2)
        // P(x) = ------------------- * e
        //        stdDev * sqrt(2*pi)
        
        let multiplier = 1.0/(standardDeviation*sqrt(2*Double.pi))
        let expPart = exp((-1*pow(x-mean, 2.0))/(2*(Square(standardDeviation))))
        return multiplier * expPart
    }
    
    public static func CumulativeTo(_ x: Double, mean: Double = 0, standardDeviation: Double = 1) -> Double {
        let invsqrt2 = -0.707106781186547524400844362104
        let result = ErrorFunctionCumulativeTo(invsqrt2 * x)
        return 0.5*result
    }
    
    public static func ErrorFunctionCumulativeTo(_ x: Double) -> Double {
        let z = abs(x)
        let t = 2.0/(2.0 + z)
        let ty = 4*t - 2
        
        let coeffecients = [
            -1.3026537197817094, 6.4196979235649026e-1,
            1.9476473204185836e-2, -9.561514786808631e-3, -9.46595344482036e-4,
            3.66839497852761e-4, 4.2523324806907e-5, -2.0278578112534e-5,
            -1.624290004647e-6, 1.303655835580e-6, 1.5626441722e-8, -8.5238095915e-8,
            6.529054439e-9, 5.059343495e-9, -9.91364156e-10, -2.27365122e-10,
            9.6467911e-11, 2.394038e-12, -6.886027e-12, 8.94487e-13, 3.13092e-13,
            -1.12708e-13, 3.81e-16, 7.106e-15, -1.523e-15, -9.4e-17, 1.21e-16, -2.8e-17
        ]
        
        let ncof = coeffecients.count
        var d = 0.0
        var dd = 0.0
        
        for j in stride(from: ncof - 1, to: 0, by: -1) {
            let tmp = d
            d = ty*d - dd + coeffecients[j]
            dd = tmp
        }
        
        let half = (coeffecients[0] + ty * d)/2
        let insideExp: Double = (-z * z) + half - dd
        let ans = t * exp(insideExp)
        if x >= 0.0 {
            return ans
        }else{
            return 2.0-ans
        }
    }
    
    private static func InverseErrorFunctionCumulativeTo(p: Double) -> Double {
        // From page 265 of numerical recipes
        
        if p >= 2.0 {
            return -100
        }
        if p <= 0.0 {
            return 100
        }
        
        var pp = p
        if p < 1.0 {
            pp = 2-p
        }
        
        let t = sqrt(-2*log(pp/2.0)) //initial guess
        var x = -0.70711*((2.30753 + t*0.27061)/(1.0 + t*(0.99229 + t*0.04481)) - t)
        
        for _ in 0..<2 {
            let err = ErrorFunctionCumulativeTo(x) - pp
            x += err/(1.12837916709551257*exp(-(Square(x))) - x*err) // Halley
        }
        
        if p > 1.0 {
            return x
        }else{
            return -x
        }
    }
    
    public static func InverseCumulativeTo(_ x: Double, _ mean: Double = 0, _ standardDeviation: Double = 1) -> Double {
        return mean - sqrt(2)*standardDeviation*InverseErrorFunctionCumulativeTo(p: 2*x)
    }
    
    public var description: String { return String(format: "μ={0:0.0000}, σ={1:0.0000}", Mean, StandardDeviation) }
    
}
