//
//  DrawMargin.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 7/7/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

internal class DrawMargin {
    public static func GetDrawMarginFromDrawProbability(drawProbability: Double, beta: Double) -> Double {
        // Derived from TrueSkill technical report (MSR-TR-2006-80), page 6

        // draw probability = 2 * CDF(margin/(sqrt(n1+n2)*beta)) -1

        // implies
        //
        // margin = inversecdf((draw probability + 1)/2) * sqrt(n1+n2) * beta
        // n1 and n2 are the number of players on each team
        
        return GaussianDistribution.InverseCumulativeTo(0.5*(drawProbability + 1))*sqrt(2)*beta
    }
}
