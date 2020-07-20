//
//  Rating.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 4/26/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

public class Rating: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(Mean)
        hasher.combine(StandardDeviation)
    }
    
    public static func == (lhs: Rating, rhs: Rating) -> Bool {
        return lhs.Mean == rhs.Mean && lhs.StandardDeviation == rhs.StandardDeviation
    }
    
    
    private var _ConservativeStandardDeviationMultiplier: Double
    public private(set) var Mean: Double
    public private(set) var StandardDeviation: Double
    
    
    init(mean: Double, standardDeviation: Double, conservativeStandardDeviationMultiplier: Double = 3) {
        self.Mean = mean
        self.StandardDeviation = standardDeviation
        self._ConservativeStandardDeviationMultiplier = conservativeStandardDeviationMultiplier
    }
    
    public var ConservativeRating: Double {
        return Mean - _ConservativeStandardDeviationMultiplier*StandardDeviation
    }
    
    public static func GetPartialUpdate(_ prior: Rating, _ fullPosterior: Rating, _ updatePercentage: Double) -> Rating {
        let priorGaussian = GaussianDistribution(mean: prior.Mean, standardDeviation: prior.StandardDeviation)
        let posteriorGaussian = GaussianDistribution(mean: fullPosterior.Mean, standardDeviation: fullPosterior.StandardDeviation)
        
        let precisionDifference = posteriorGaussian.Precision - priorGaussian.Precision
        let partialPrecisionDifference = updatePercentage * precisionDifference
        
        let precisonMeanDifference = posteriorGaussian.PrecisionMean - priorGaussian.PrecisionMean
        let partialPrecisionMeanDifference = updatePercentage*precisonMeanDifference
        
        let partialPosteriorGaussian = GaussianDistribution.FromPrecisionMean(precisionMean: priorGaussian.PrecisionMean + partialPrecisionMeanDifference, precision: priorGaussian.Precision + partialPrecisionDifference)
        
        return Rating(mean: partialPosteriorGaussian.Mean, standardDeviation: partialPosteriorGaussian.StandardDeviation, conservativeStandardDeviationMultiplier: prior._ConservativeStandardDeviationMultiplier)
    }
    
     public var description: String { return String(format: "μ={0:0.0000}, σ={1:0.0000}", Mean, StandardDeviation) }
}
