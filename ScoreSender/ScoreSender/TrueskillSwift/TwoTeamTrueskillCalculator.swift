//
//  TwoTeamTrueskillCalculator.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 7/6/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

public class TwoTeamTrueSkillCalculator: SkillCalculator {
    internal var _SupportedOptions: SupportedOptions
    internal var _PlayersPerTeamAllowed: PlayersRange
    internal var _TotalTeamsAllowed: TeamsRange
    
    init() {
        _SupportedOptions = SupportedOptions.None
        _PlayersPerTeamAllowed = PlayersRange.AtLeast(minValue: 1)
        _TotalTeamsAllowed = TeamsRange.Exactly(value: 2)
    }
    
    func CalculateNewRatings<TPlayer>(gameInfo: GameInfo, teams: [[TPlayer : Rating]], teamRanks: [Int]) -> [TPlayer : Rating] where TPlayer : Hashable {
        ValidateTeamCountAndPlayersCountPerTeam(teams: teams)
        
        let (teamsSorted, teamRanksSorted) = RankSorter.Sort(teams: teams, teamRanks: teamRanks)
        
        let team1 = teamsSorted[0]
        let team2 = teamsSorted[1]
        
        let wasDraw = teamRanksSorted[0] == teamRanksSorted[1]
        
        var results: [TPlayer: Rating] = [:]
        
        var winnerComparison: PairwiseComparison = PairwiseComparison.Win
        if wasDraw {
            winnerComparison = PairwiseComparison.Draw
        }
        
        UpdatePlayerRatings(gameInfo: gameInfo, newPlayerRatings: &results, selfTeam: team1, otherTeam: team2, selfToOtherTeamComparison: winnerComparison)
        
        var loserComparison = PairwiseComparison.Lose
        if wasDraw {
            loserComparison = PairwiseComparison.Draw
        }
        
        UpdatePlayerRatings(gameInfo: gameInfo, newPlayerRatings: &results, selfTeam: team2, otherTeam: team1, selfToOtherTeamComparison: loserComparison)
        
        return results
    }
    
    func CalculateNewRatings<TPlayer>(gameInfo: GameInfo, teams: [[TPlayer : Rating]], teamRanks: Int...) -> [TPlayer : Rating] where TPlayer : Hashable {
        return CalculateNewRatings(gameInfo: gameInfo, teams: teams, teamRanks: teamRanks)
    }
    
    private func UpdatePlayerRatings<TPlayer>(gameInfo: GameInfo,
                                      newPlayerRatings: inout [TPlayer: Rating],
                                      selfTeam: [TPlayer: Rating],
                                      otherTeam: [TPlayer: Rating],
                                      selfToOtherTeamComparison: PairwiseComparison) {
        
        let drawMargin = DrawMargin.GetDrawMarginFromDrawProbability(drawProbability: gameInfo.drawProbability, beta: gameInfo.beta)
        
        let betaSquared = Square(gameInfo.beta)
        let tauSquared = Square(gameInfo.dynamicsFactor)
        
        let totalPlayers = Double(selfTeam.count + otherTeam.count)
        
        let selfMeanSum = selfTeam.values.map({$0.Mean}).reduce(0, +)
        let otherTeamMeanSum = otherTeam.values.map({$0.Mean}).reduce(0, +)
        
        let x = selfTeam.values.map({Square($0.StandardDeviation)}).reduce(0, +)
        let y = otherTeam.values.map({Square($0.StandardDeviation)}).reduce(0, +)
        
        let c = sqrt(x + y + totalPlayers * betaSquared)
        
        var winningMean = selfMeanSum
        var losingMean = otherTeamMeanSum
        
        switch(selfToOtherTeamComparison) {
        case .Win:
            break;
        case .Draw:
            break
        case .Lose:
            winningMean = otherTeamMeanSum
            losingMean = selfMeanSum
            break
        }
        
        let meanDelta = winningMean - losingMean
        
        var v: Double
        var w: Double
        var rankMultiplier: Double
        
        if selfToOtherTeamComparison != .Draw {
            v = TruncatedGaussianCorrectionFunctions.VExceedsMargin(teamPerformanceDifference: meanDelta, drawMargin: drawMargin, c: c)
            w = TruncatedGaussianCorrectionFunctions.WExceedsMargin(teamPerformanceDifference: meanDelta, drawMargin: drawMargin, c: c)
            rankMultiplier = Double(Int(selfToOtherTeamComparison.rawValue))
        } else {
            v = TruncatedGaussianCorrectionFunctions.VWithinMargin(teamPerformanceDifference: meanDelta, drawMargin: drawMargin, c: c)
            w = TruncatedGaussianCorrectionFunctions.WWithinMargin(teamPerformanceDifference: meanDelta, drawMargin: drawMargin, c: c)
            rankMultiplier = 1
        }
                
        for teamPlayerRatingPair in selfTeam {
            let previousPlayerRating = teamPlayerRatingPair.value

            
            let meanMultiplier = (Square(previousPlayerRating.StandardDeviation) + tauSquared)/c
            let stdDevMultiplier = (Square(previousPlayerRating.StandardDeviation) + tauSquared)/Square(c)
            
            let playerMeanDelta = rankMultiplier * meanMultiplier * v
            let newMean = previousPlayerRating.Mean + playerMeanDelta
            
            let newStdDev = sqrt((Square(previousPlayerRating.StandardDeviation) + tauSquared) * (1 - w * stdDevMultiplier))
            newPlayerRatings[teamPlayerRatingPair.key] = Rating(mean: newMean, standardDeviation: newStdDev)
        }
    }
    
    func CalculateMatchQuality<TPlayer>(gameInfo: GameInfo, teams: [[TPlayer : Rating]]) -> Double where TPlayer : Hashable {
       ValidateTeamCountAndPlayersCountPerTeam(teams: teams)
        // We've verified that there's just two teams
        let team1 = teams.first!.values
        let team1Count = team1.count
        
        let team2 = teams.last!.values
        let team2Count = team2.count
        
        let totalPlayers: Double = Double(team1Count + team2Count)
        let betaSquared = Square(gameInfo.beta)
        
        let team1MeanSum = team1.map({$0.Mean}).reduce(0, +)
        let team1StdDevSquared = team1.map({Square($0.StandardDeviation)}).reduce(0, +)
        
        let team2MeanSum = team2.map({$0.Mean}).reduce(0, +)
        let team2StdDevSquared = team2.map({Square($0.StandardDeviation)}).reduce(0, +)
        
        // This comes from equation 4.1 in the TrueSkill paper on page 8
        // The equation was broken up into the part under the square root sign and
        // the exponential part to make the code easier to read.
        let sqrtPart = sqrt((totalPlayers * betaSquared) / (totalPlayers * betaSquared + team1StdDevSquared + team2StdDevSquared))
        
    
        let expPart = exp((-1 * Square(team1MeanSum-Double(team2MeanSum))) / (2 * (totalPlayers * betaSquared + team1StdDevSquared + team2StdDevSquared)))
        
//        let team1MeanSum =
        return expPart*sqrtPart
    }
}
