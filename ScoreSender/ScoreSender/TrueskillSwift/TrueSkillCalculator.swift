//
//  TrueSkillCalculator.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 7/16/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

public class TrueSkillCalculator {
    
    private static var _Calculator = TwoTeamTrueSkillCalculator()
    
    public static func CalculateNewRatings<TPlayer>(gameInfo: GameInfo, teams: [[TPlayer: Rating]], teamRanks: Int...) -> [TPlayer: Rating] {
        return _Calculator.CalculateNewRatings(gameInfo: gameInfo, teams: teams, teamRanks: teamRanks)
    }
    
    public static func CalculateMatchQuality<TPlayer>(gameInfo: GameInfo, teams: [[TPlayer: Rating]]) -> Double {
        return _Calculator.CalculateMatchQuality(gameInfo: gameInfo, teams: teams)
    }
}
