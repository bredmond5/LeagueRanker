//
//  FactorGraphTrueskillCalculator.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 7/15/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

class FactorGraphTrueskillCalculator: SkillCalculator {
    func CalculateNewRatings<TPlayer>(gameInfo: GameInfo, teams: [[TPlayer : Rating]], teamRanks: [Int]) -> [TPlayer : Rating] where TPlayer : Hashable {
        return [:]
    }
    
    var _SupportedOptions: SupportedOptions
    var _PlayersPerTeamAllowed: PlayersRange
    var _TotalTeamsAllowed: TeamsRange
    
    init() {
        _SupportedOptions = SupportedOptions.None
        _PlayersPerTeamAllowed = PlayersRange.AtLeast(minValue: 1)
        _TotalTeamsAllowed = TeamsRange.Exactly(value: 2)
    }
    
    func CalculateNewRatings<TPlayer>(gameInfo: GameInfo, teams: [[TPlayer : Rating]], teamRanks: Int...) -> [TPlayer : Rating] where TPlayer : Hashable {
//        ValidateTeamCountAndPlayersCountPerTeam(teams: teams)
//
//        let (sortedTeams, sortedTeamRanks) = RankSorter.Sort(teams: teams, teamRanks: teamRanks)
//
//        let factorGraph = TrueskillFactorGraph<TPlayer>(gameInfo: gameInfo, teams: teams, teamRanks: teamRanks)
//        factorGraph.buildGraph()
//        factorGraph.runSchedule()
//
//        let probabilityOfOutcome = factorGraph.GetProbabilityOfRanking()
//
//        return factorGraph.getUpdatedRankings()
        return [:]
    }
    
    func CalculateMatchQuality<TPlayer>(gameInfo: GameInfo, teams: [[TPlayer : Rating]]) -> Double where TPlayer : Hashable {
        return 0.0
    }
    
    
}
