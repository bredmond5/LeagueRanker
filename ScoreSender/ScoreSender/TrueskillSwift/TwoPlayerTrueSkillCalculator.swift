//
//  TwoPlayerTrueSkillCalculator.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 4/26/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

enum TwoPlayerTrueSkillCalculatorErrors: Error {
    case nullGameInfo
}

class TwoPlayerTrueSkillCalculator : SkillCalculator {
    func CalculateNewRatings<TPlayer>(gameInfo: GameInfo, teams: [[TPlayer : Rating]], teamRanks: [Int]) -> [TPlayer : Rating] where TPlayer : Hashable {
        ValidateTeamCountAndPlayersCountPerTeam(teams: teams)
        
        let (teamsSorted, teamRanksSorted) = RankSorter.Sort(teams: teams, teamRanks: teamRanks)
                
        let winningTeam = teamsSorted[0]
        let winner = Array(winningTeam.keys)[0]
        let winnerPreviousRating = winningTeam[winner]
        
        let losingTeam = teamsSorted[1]
        let loser = Array(losingTeam.keys)[0]
        let loserPreviousRating = losingTeam[loser]
        
        let wasDraw = teamRanksSorted[0] == teamRanksSorted[1]
        
        var results: [TPlayer: Rating] = [:]
        
        var winnerComparison: PairwiseComparison = PairwiseComparison.Win
        if wasDraw {
            winnerComparison = PairwiseComparison.Draw
        }
        results[winner] = CalculateNewRating(gameInfo: gameInfo, selfRating: winnerPreviousRating!, opponentRating: loserPreviousRating!, comparison: winnerComparison)
        
        var loserComparison = PairwiseComparison.Lose
        if wasDraw {
            loserComparison = PairwiseComparison.Draw
        }
        
        results[loser] = CalculateNewRating(gameInfo: gameInfo, selfRating: loserPreviousRating!, opponentRating: winnerPreviousRating!, comparison: loserComparison)
        
        return results
    }
    
    
    internal var _SupportedOptions: SupportedOptions
    internal var _PlayersPerTeamAllowed: PlayersRange
    internal var _TotalTeamsAllowed: TeamsRange
    
    init() {
        _SupportedOptions = SupportedOptions.None
        _PlayersPerTeamAllowed = PlayersRange.Exactly(value: 1)
        _TotalTeamsAllowed = TeamsRange.Exactly(value: 2)
    }
    
    func CalculateNewRatings<TPlayer>(gameInfo: GameInfo, teams: [[TPlayer : Rating]], teamRanks: Int...) -> [TPlayer : Rating] where TPlayer : Hashable {
//        guard let gameInfo = gameInfo else {
//            throw TwoPlayerTrueSkillCalculatorErrors.nullGameInfo
//        }
        return CalculateNewRatings(gameInfo: gameInfo, teams: teams, teamRanks: teamRanks)
        
    }
    
    private func CalculateNewRating(gameInfo: GameInfo, selfRating: Rating, opponentRating: Rating, comparison: PairwiseComparison) -> Rating {
        
        let drawMargin = DrawMargin.GetDrawMarginFromDrawProbability(drawProbability: gameInfo.drawProbability, beta: gameInfo.beta)
        
        let c = sqrt(
            Square(selfRating.StandardDeviation)
            +
            Square(opponentRating.StandardDeviation)
            +
            2*Square(gameInfo.beta)
        )
        
        var winningMean = selfRating.Mean
        var losingMean = opponentRating.Mean
        
        switch(comparison) {
        case .Win:
            break
        case .Draw:
            break
        case .Lose:
            winningMean = opponentRating.Mean
            losingMean = selfRating.Mean
            break
        }
        
        let meanDelta = winningMean - losingMean
        
        var v: Double
        var w: Double
        let rankMultiplier: Double
        
        if comparison != .Draw {
            v = TruncatedGaussianCorrectionFunctions.VExceedsMargin(teamPerformanceDifference: meanDelta, drawMargin: drawMargin, c: c)
            w = TruncatedGaussianCorrectionFunctions.WExceedsMargin(teamPerformanceDifference: meanDelta, drawMargin: drawMargin, c: c)
            rankMultiplier = Double(comparison.rawValue)
        } else {
            v = TruncatedGaussianCorrectionFunctions.VWithinMargin(teamPerformanceDifference: meanDelta, drawMargin: drawMargin, c: c)
            w = TruncatedGaussianCorrectionFunctions.WWithinMargin(teamPerformanceDifference: meanDelta, drawMargin: drawMargin, c: c)
            rankMultiplier = 1
        }
        
        let meanMultiplier = (Square(selfRating.StandardDeviation) + Square(gameInfo.dynamicsFactor))/c
        
        let varianceWithinDynamics = Square(selfRating.StandardDeviation) + Square(gameInfo.dynamicsFactor)
        let stdDevMultiplier = varianceWithinDynamics/Square(c)
        
        let newMean = selfRating.Mean + (rankMultiplier*meanMultiplier*v)
        let newStdDev = sqrt(varianceWithinDynamics*(1-w*stdDevMultiplier))
        
        return Rating(mean: newMean, standardDeviation: newStdDev)
    }
    
    func CalculateMatchQuality<TPlayer>(gameInfo: GameInfo, teams: [[TPlayer : Rating]]) -> Double where TPlayer: Hashable {
//        guard let gameInfo = gameInfo else {
//            TwoPlayerTrueSkillCalculatorErrors.nullGameInfo
//        }
        
        ValidateTeamCountAndPlayersCountPerTeam(teams: teams)
        
        let player1Rating = teams.first!.values.first
        let player2Rating = teams.last!.values.first
        
        let betaSquared = Square(gameInfo.beta)
        let player1SigmaSquared = Square(player1Rating!.StandardDeviation)
        let player2SigmaSquared = Square(player2Rating!.StandardDeviation)
        
//        let sqrtPart = sqrt(
//            exp(-1*Square(player1Rating!.Mean - player2Rating!.Mean))
//            / (2*(2*betaSquared + player1SigmaSquared + player2SigmaSquared)))
        let sqrtPart = sqrt(
            (2*betaSquared)
            / (2*betaSquared + player1SigmaSquared + player2SigmaSquared))
        
        let expPart = exp(
            (-1*Square(player1Rating!.Mean - player2Rating!.Mean))
            / (2*(2*betaSquared + player1SigmaSquared + player2SigmaSquared)))
        
        return sqrtPart * expPart
    }
}
