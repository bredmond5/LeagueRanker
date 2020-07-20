//
//  TwoTeamTrueskillTests.swift
//  TrueskillSwiftTests
//
//  Created by Brice Redmond on 7/12/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import XCTest

class TwoTeamTrueskillCalculatorTests: XCTestCase {

    private let ErrorTolerance = 0.085;
    
    private var player1: Player<Int>?
    private var player2: Player<Int>?
    private var player3: Player<Int>?
    private var player4: Player<Int>?
   
    private var gameInfo: GameInfo?
    private var teams: [[Player<Int> : Rating]]?
   
    private var calculator: SkillCalculator {
        return TwoTeamTrueSkillCalculator()
    }
    
    override internal func setUp() {
        player1 = Player(id: 1)
        player2 = Player(id: 2)
        player3 = Player(id: 3)
        player4 = Player(id: 4)
        
        gameInfo = GameInfo.DefaultGameInfo
        
        let team1 = Team().AddPlayer(player: player1!, rating: gameInfo!.DefaultRating).AddPlayer(player: player2!, rating: gameInfo!.DefaultRating)
        let team2 = Team().AddPlayer(player: player3!, rating: gameInfo!.DefaultRating).AddPlayer(player: player4!, rating: gameInfo!.DefaultRating)
        
        teams = Teams.Concat(team1, team2)
    }
    
    func testTwoPlayerNotDrawn() {
        let newRatings = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams!, teamRanks: 1,2)
        
        let player1NewRating = newRatings[player1!]
        XCTAssertEqual(29.39583201999924, player1NewRating!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.171475587326186, player1NewRating!.StandardDeviation, accuracy: ErrorTolerance)
//        AssertRating(29.39583201999924, 7.171475587326186, player1NewRating!)
        
        let player2NewRating = newRatings[player2!]
        XCTAssertEqual(20.60416798000076, player2NewRating!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.171475587326186, player2NewRating!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.447, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams!), accuracy: ErrorTolerance)
        
    }
    
    func testTwoPlayerDrawn() {
        let newRatings = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams!, teamRanks: 1,1)
        
        let player1NewRating = newRatings[player1!]
        XCTAssertEqual(25.0, player1NewRating!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(6.4575196623173081, player1NewRating!.StandardDeviation, accuracy: ErrorTolerance)
        
        let player2NewRating = newRatings[player2!]
        XCTAssertEqual(25.0, player2NewRating!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(6.4575196623173081, player2NewRating!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.447, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams!), accuracy: ErrorTolerance)
    }
    
    func testOneOnOneMassiveUpsetDraw() {
        let team1 = Team().AddPlayer(player: player1!, rating: gameInfo!.DefaultRating)
        let team2 = Team().AddPlayer(player: player2!, rating: Rating(mean: 50, standardDeviation: 12.5));
        let teams = Teams.Concat(team1, team2);

        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1, 1)

        // Winners
        let player1NewRating = newRatingsWinLose[player1!]
        XCTAssertEqual(31.662, player1NewRating!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.137, player1NewRating!.StandardDeviation, accuracy: ErrorTolerance)

        // Losers
        let player2NewRating = newRatingsWinLose[player2!]
        XCTAssertEqual(35.010, player2NewRating!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.910, player2NewRating!.StandardDeviation, accuracy: ErrorTolerance)

        XCTAssertEqual(0.110, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testTwoPlayerChessNotDrawn() {
        let gameInfo = GameInfo(initialMean: 1200.0, initialStandardDeviation: 1200.0 / 3.0, beta: 200.0, dynamicsFactor: 1200.0 / 300.0, drawProbability: 0.03)
        
        let team1 = Team(firstPlayer: player1!, playerRating: Rating(mean: 1301.0007, standardDeviation: 42.9232))
        let team2 = Team(firstPlayer: player2!, playerRating: Rating(mean: 1188.7560, standardDeviation: 42.5570))

        let newRatings = calculator.CalculateNewRatings(gameInfo: gameInfo, teams: Teams.Concat(team1, team2), teamRanks: 1, 2)

        let player1NewRating = newRatings[player1!]
        
        XCTAssertEqual(1304.7820836053318, player1NewRating!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(42.843513887848658, player1NewRating!.StandardDeviation, accuracy: ErrorTolerance)
        
        let player2NewRating = newRatings[player2!]
        XCTAssertEqual(1185.0383099003536, player2NewRating!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(42.485604606897752, player2NewRating!.StandardDeviation, accuracy: ErrorTolerance)
    }
    
    func testSimpleTwoOnTwo() {
        
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams!, teamRanks: 1,2)
        
        //winners
        XCTAssertEqual(28.108, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(28.108, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)

        //losers
        XCTAssertEqual(21.892, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(21.892, newRatingsWinLose[player4!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.774, newRatingsWinLose[player4!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.447, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams!), accuracy: ErrorTolerance)
    }
    
    func testTwoOnTwoDraw() {
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams!, teamRanks: 1,1)
        
        //winners
        XCTAssertEqual(25, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.455, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(25, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.455, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)

        //losers
        XCTAssertEqual(25, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.455, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(25, newRatingsWinLose[player4!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.455, newRatingsWinLose[player4!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.447, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams!), accuracy: ErrorTolerance);
    }
    
    func testTwoOnTwoUnbalancedDraw() {
        let player1 = Player(id: 1)
        let player2 = Player(id: 2)

        let gameInfo = GameInfo.DefaultGameInfo

        let team1 = Team()
            .AddPlayer(player: player1, rating: Rating(mean: 15, standardDeviation: 8))
            .AddPlayer(player: player2, rating: Rating(mean: 20, standardDeviation: 6))

        let player3 = Player(id: 3);
        let player4 = Player(id: 4);

        let team2 = Team()
            .AddPlayer(player: player3, rating: Rating(mean: 25, standardDeviation: 4))
            .AddPlayer(player: player4, rating: Rating(mean: 30, standardDeviation: 3))
        
        let teams = Teams.Concat(team1, team2)
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo, teams: teams, teamRanks: 1, 1)
        
        XCTAssertEqual(21.570, newRatingsWinLose[player1]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(6.556, newRatingsWinLose[player1]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(23.357, newRatingsWinLose[player2]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(5.418, newRatingsWinLose[player2]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(23.357, newRatingsWinLose[player3]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(3.833, newRatingsWinLose[player3]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(29.075, newRatingsWinLose[player4]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(2.931, newRatingsWinLose[player4]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.214, calculator.CalculateMatchQuality(gameInfo: gameInfo, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testTwoOnTwoUpset() {
        let player1 = Player(id: 1)
        let player2 = Player(id: 2)

        let gameInfo = GameInfo.DefaultGameInfo

        let team1 = Team()
           .AddPlayer(player: player1, rating: Rating(mean: 20, standardDeviation: 8))
           .AddPlayer(player: player2, rating: Rating(mean: 25, standardDeviation: 6))

        let player3 = Player(id: 3);
        let player4 = Player(id: 4);

        let team2 = Team()
           .AddPlayer(player: player3, rating: Rating(mean: 35, standardDeviation: 7))
           .AddPlayer(player: player4, rating: Rating(mean: 40, standardDeviation: 5))
       
        let teams = Teams.Concat(team1, team2)
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo, teams: teams, teamRanks: 1, 2)
        
        XCTAssertEqual(29.698, newRatingsWinLose[player1]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.008, newRatingsWinLose[player1]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(30.455, newRatingsWinLose[player2]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(5.594, newRatingsWinLose[player2]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(27.575, newRatingsWinLose[player3]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(6.346, newRatingsWinLose[player3]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(36.211, newRatingsWinLose[player4]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.768, newRatingsWinLose[player4]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.084, calculator.CalculateMatchQuality(gameInfo: gameInfo, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testFourOnFour() {
        let team1 = Team()
            .AddPlayer(player: player1!, rating: gameInfo!.DefaultRating)
            .AddPlayer(player: player2!, rating: gameInfo!.DefaultRating)
            .AddPlayer(player: player3!, rating: gameInfo!.DefaultRating)
            .AddPlayer(player: player4!, rating: gameInfo!.DefaultRating)
        
        let player5 = Player(id: 5)
        let player6 = Player(id: 6)
        let player7 = Player(id: 7)
        let player8 = Player(id: 8)
        
        let team2 = Team()
            .AddPlayer(player: player5, rating: gameInfo!.DefaultRating)
            .AddPlayer(player: player6, rating: gameInfo!.DefaultRating)
            .AddPlayer(player: player7, rating: gameInfo!.DefaultRating)
            .AddPlayer(player: player8, rating: gameInfo!.DefaultRating)
        
        let teams = Teams.Concat(team1, team2)

        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1, 2)
        
        XCTAssertEqual(27.198, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(8.059, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(27.198, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(8.059, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(27.198, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(8.059, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(27.198, newRatingsWinLose[player4!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(8.059, newRatingsWinLose[player4!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(22.802, newRatingsWinLose[player5]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(8.059, newRatingsWinLose[player5]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(22.802, newRatingsWinLose[player6]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(8.059, newRatingsWinLose[player6]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(22.802, newRatingsWinLose[player7]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(8.059, newRatingsWinLose[player7]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(22.802, newRatingsWinLose[player8]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(8.059, newRatingsWinLose[player8]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.447, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testSimpleOneOnTwo() {
        let team1 = Team().AddPlayer(player: player1!, rating: gameInfo!.DefaultRating)
        
        let team2 = Team().AddPlayer(player: player2!, rating: gameInfo!.DefaultRating).AddPlayer(player: player3!, rating: gameInfo!.DefaultRating)
        
        let teams = Teams.Concat(team1,team2)
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1,2)
        
        XCTAssertEqual(33.730, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.317, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(16.270, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.317, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(16.270, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.317, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.135, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testSomewhatBalancedOneOnTwo() {
        let team1 = Team().AddPlayer(player: player1!, rating: Rating(mean: 40, standardDeviation: 6))
        
        let team2 = Team().AddPlayer(player: player2!, rating: Rating(mean: 20, standardDeviation: 7)).AddPlayer(player: player3!, rating: Rating(mean: 25, standardDeviation: 7))
        
        let teams = Teams.Concat(team1,team2)
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1,2)
        
        XCTAssertEqual(42.744, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(5.602, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(16.266, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(6.359, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(20.123, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.028, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.478, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testSimpleOneOnThree() {
        let team1 = Team().AddPlayer(player: player1!, rating: gameInfo!.DefaultRating)
        
        let team2 = Team().AddPlayer(player: player2!, rating: gameInfo!.DefaultRating).AddPlayer(player: player3!, rating: gameInfo!.DefaultRating).AddPlayer(player: player4!, rating: gameInfo!.DefaultRating)
        
        let teams = Teams.Concat(team1,team2)
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1,2)
        
        XCTAssertEqual(36.337, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.527, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(13.663, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.527, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(13.663, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.527, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(13.663, newRatingsWinLose[player4!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.527, newRatingsWinLose[player4!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.012, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testOneOnTwoDraw() {
        let team1 = Team().AddPlayer(player: player1!, rating: gameInfo!.DefaultRating)

        let team2 = Team().AddPlayer(player: player2!, rating: gameInfo!.DefaultRating).AddPlayer(player: player3!, rating: gameInfo!.DefaultRating)
        
        let teams = Teams.Concat(team1,team2)
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1,1)
        
        XCTAssertEqual(31.660, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.138, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(18.340, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.138, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(18.340, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.138, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.135, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testOneOnThreeDraw() {
        let team1 = Team().AddPlayer(player: player1!, rating: gameInfo!.DefaultRating)
        
        let team2 = Team().AddPlayer(player: player2!, rating: gameInfo!.DefaultRating).AddPlayer(player: player3!, rating: gameInfo!.DefaultRating).AddPlayer(player: player4!, rating: gameInfo!.DefaultRating)
        
        let teams = Teams.Concat(team1,team2)
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1,1)
        
        XCTAssertEqual(34.990, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.445, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(15.010, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.455, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(15.010, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.455, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(15.010, newRatingsWinLose[player4!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.455, newRatingsWinLose[player4!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.012, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testSimpleOneOnSeven() {
        let team1 = Team()
            .AddPlayer(player: player1!, rating: gameInfo!.DefaultRating)
            
        
        let player5 = Player(id: 5)
        let player6 = Player(id: 6)
        let player7 = Player(id: 7)
        let player8 = Player(id: 8)
        
        let team2 = Team()
            .AddPlayer(player: player2!, rating: gameInfo!.DefaultRating)
            .AddPlayer(player: player3!, rating: gameInfo!.DefaultRating)
            .AddPlayer(player: player4!, rating: gameInfo!.DefaultRating)
            .AddPlayer(player: player5, rating: gameInfo!.DefaultRating)
            .AddPlayer(player: player6, rating: gameInfo!.DefaultRating)
            .AddPlayer(player: player7, rating: gameInfo!.DefaultRating)
            .AddPlayer(player: player8, rating: gameInfo!.DefaultRating)
        
        let teams = Teams.Concat(team1, team2)

        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1, 2)
        
        XCTAssertEqual(40.582, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.917, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(9.418, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.917, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(9.418, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.917, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(9.418, newRatingsWinLose[player4!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.917, newRatingsWinLose[player4!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(9.418, newRatingsWinLose[player5]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.917, newRatingsWinLose[player5]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(9.418, newRatingsWinLose[player6]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.917, newRatingsWinLose[player6]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(9.418, newRatingsWinLose[player7]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.917, newRatingsWinLose[player7]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(9.418, newRatingsWinLose[player8]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.917, newRatingsWinLose[player8]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.000, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testThreeOnTwo() {
        let player5 = Player(id: 5)
        let team1 = Team()
            .AddPlayer(player: player1!, rating: Rating(mean: 28, standardDeviation: 7))
            .AddPlayer(player: player2!, rating: Rating(mean: 27, standardDeviation: 6))
            .AddPlayer(player: player3!, rating: Rating(mean: 26, standardDeviation: 5))


        let team2 = Team()
            .AddPlayer(player: player4!, rating: Rating(mean: 30, standardDeviation: 4))
            .AddPlayer(player: player5, rating: Rating(mean: 31, standardDeviation: 3))
           
        let teams = Teams.Concat(team1, team2)

        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1, 2)
        
        XCTAssertEqual(28.658, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(6.770, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(27.484, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(5.856, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(26.336, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.917, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(29.785, newRatingsWinLose[player4!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(3.958, newRatingsWinLose[player4!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(30.879, newRatingsWinLose[player5]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(2.983, newRatingsWinLose[player5]!.StandardDeviation, accuracy: ErrorTolerance)
        
        let newRatingsWinLoseUpset = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: Teams.Concat(team1, team2), teamRanks: 2,1)
        
        XCTAssertEqual(32.012, newRatingsWinLoseUpset[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(3.887, newRatingsWinLoseUpset[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
           
        XCTAssertEqual(32.132, newRatingsWinLoseUpset[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(2.949, newRatingsWinLoseUpset[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
           
        XCTAssertEqual(21.840, newRatingsWinLoseUpset[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(6.314, newRatingsWinLoseUpset[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(22.474, newRatingsWinLoseUpset[player4!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(5.575, newRatingsWinLoseUpset[player4!]!.StandardDeviation, accuracy: ErrorTolerance)
           
        XCTAssertEqual(22.857, newRatingsWinLoseUpset[player5]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.757, newRatingsWinLoseUpset[player5]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.254, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams), accuracy: ErrorTolerance)
    }
}
