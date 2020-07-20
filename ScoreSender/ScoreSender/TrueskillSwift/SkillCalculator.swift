//
//  SkillCalculator.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 4/26/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

//public class SkillCalculator {
//    
//
//    init(supportedOptions: SupportedOptions, totalTeamsAllowed: TeamsRange, playerPerTeamAllowed: PlayersRange) {
//        _SupportedOptions = supportedOptions
//        _TotalTeamsAllowed = totalTeamsAllowed
//        _PlayersPerTeamAllowed = playerPerTeamAllowed
//    }
//}
//
enum SkillCalculatorError: Error {
//    case teamsDictionary(String)
//    case gameInfo
    case invalidRange(String)
    case invalidCount(String)
}
//


struct SupportedOptions: OptionSet
{
    let rawValue: UInt8
    
    static let None = SupportedOptions([])
    static let PartialPlay = SupportedOptions(rawValue: 0x01)
    static let PartialUpdate = SupportedOptions(rawValue: 0x02)
}

//enum SupportedOptions: Int, BinaryInteger {
//    typealias Words = Int
//
//    typealias Magnitude = Int
//
//    static func + (lhs: SupportedOptions, rhs: SupportedOptions) -> SupportedOptions {
//        return lhs + rhs
//    }
//
//    typealias IntegerLiteralType = Int
//
//    case None = 0x00
//    case PartialPlay = 0x01
//    case PartialUpdate = 0x02
//}

protocol SkillCalculator {
    var _SupportedOptions: SupportedOptions { get }
    var _PlayersPerTeamAllowed: PlayersRange { get }
    var  _TotalTeamsAllowed: TeamsRange { get }
    
    func CalculateNewRatings<TPlayer>(gameInfo: GameInfo, teams: [[TPlayer: Rating]], teamRanks: Int...) -> [TPlayer: Rating]

    func CalculateMatchQuality<TPlayer>(gameInfo: GameInfo, teams: [[TPlayer: Rating]]) -> Double

    func CalculateNewRatings<TPlayer>(gameInfo: GameInfo, teams: [[TPlayer: Rating]], teamRanks: [Int]) -> [TPlayer: Rating]
}

extension SkillCalculator {
    
    internal func IsSupported(_ option: SupportedOptions) -> Bool
    {
        return _SupportedOptions.intersection(option) == option
    }

    internal static func Square(_ value: Double) -> Double {
        return value*value
    }
    
    internal func ValidateTeamCountAndPlayersCountPerTeam<TPlayer> (teams: [[TPlayer: Rating]])
    {
//        do {
//            try ValidateTeamCountAndPlayersCountPerTeam(teams: teams, totalTeams: _TotalTeamsAllowed, playersPerTeam: _PlayersPerTeamAllowed)
//        } catch SkillCalculatorError.invalidRange(let s) {
//            print(s)
//            exit(1)
//        } catch SkillCalculatorError.invalidCount(let s) {
//            print(s)
//            exit(1)
//        } catch {
//            print("Confusion!")
//        }
        try! ValidateTeamCountAndPlayersCountPerTeam(teams: teams, totalTeams: _TotalTeamsAllowed, playersPerTeam: _PlayersPerTeamAllowed)
    }

    internal func ValidateTeamCountAndPlayersCountPerTeam<TPlayer>(teams: [[TPlayer: Rating]], totalTeams: TeamsRange, playersPerTeam: PlayersRange) throws {
       
        var countOfTeams = 0
        for currentTeam in teams {
            if !playersPerTeam.IsInRange(value: currentTeam.count) {
                throw SkillCalculatorError.invalidRange("Team should have between \(playersPerTeam.Min) and \(playersPerTeam.Max) players per team but it has \(currentTeam.count) players per team")
            }
            countOfTeams += 1
        }

        if !totalTeams.IsInRange(value: countOfTeams) {
            throw SkillCalculatorError.invalidCount("There should be between \(totalTeams.Min) and \(totalTeams.Max) teams but there is \(countOfTeams) teams")
        }
    }
    
    internal func Square(_ x: Double) -> Double {
        return x*x
    }
}
