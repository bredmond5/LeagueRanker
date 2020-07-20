//
//  MultipleTeamTrueskillTests.swift
//  TrueskillSwiftTests
//
//  Created by Brice Redmond on 7/15/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import XCTest

class MultipleTeamTrueskillTests: XCTestCase {

    private let ErrorTolerance = 0.085;
    
    private var player1: Player<Int>?
    private var player2: Player<Int>?
    private var player3: Player<Int>?
    private var player4: Player<Int>?
    private var player5: Player<Int>?
    private var player6: Player<Int>?
    private var player7: Player<Int>?
    private var player8: Player<Int>?
  
    private var gameInfo: GameInfo?
    
    private var calculator: SkillCalculator {
        return FactorGraphTrueskillCalculator()
    }
    
    override func setUp() {
        player1 = Player(id: 1)
        player2 = Player(id: 2)
        player3 = Player(id: 3)
        player4 = Player(id: 4)
        player5 = Player(id: 5)
        player6 = Player(id: 6)
        player7 = Player(id: 7)
        player8 = Player(id: 8)
        
        gameInfo = GameInfo.DefaultGameInfo
    }
    
    func testTwoPlayerNotDrawn() {
        let team1 = Team().AddPlayer(player: player1!, rating: gameInfo!.DefaultRating).AddPlayer(player: player2!, rating: gameInfo!.DefaultRating)
        let team2 = Team().AddPlayer(player: player3!, rating: gameInfo!.DefaultRating).AddPlayer(player: player4!, rating: gameInfo!.DefaultRating)
        
        let teams = Teams.Concat(team1, team2)
        let newRatings = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1,2)
        
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
        let team1 = Team().AddPlayer(player: player1!, rating: gameInfo!.DefaultRating).AddPlayer(player: player2!, rating: gameInfo!.DefaultRating)
        let team2 = Team().AddPlayer(player: player3!, rating: gameInfo!.DefaultRating).AddPlayer(player: player4!, rating: gameInfo!.DefaultRating)
        
        let teams = Teams.Concat(team1, team2)
        let newRatings = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1,1)
        
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
        let team1 = Team().AddPlayer(player: player1!, rating: gameInfo!.DefaultRating).AddPlayer(player: player2!, rating: gameInfo!.DefaultRating)
        let team2 = Team().AddPlayer(player: player3!, rating: gameInfo!.DefaultRating).AddPlayer(player: player4!, rating: gameInfo!.DefaultRating)
        
        let teams = Teams.Concat(team1, team2)
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
        let team1 = Team().AddPlayer(player: player1!, rating: gameInfo!.DefaultRating).AddPlayer(player: player2!, rating: gameInfo!.DefaultRating)
        let team2 = Team().AddPlayer(player: player3!, rating: gameInfo!.DefaultRating).AddPlayer(player: player4!, rating: gameInfo!.DefaultRating)
        
        let teams = Teams.Concat(team1, team2)
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
    
    func testTwoOnFourOnTwoWinDraw() {
        let team1 = Team()
            .AddPlayer(player: player1, rating: Rating(mean: 40, standardDeviation: 4))
            .AddPlayer(player: player2, rating: Rating(mean: 45, standardDeviation: 3))
        
        let team2 = Team()
            .AddPlayer(player: player3, rating: Rating(mean: 20, standardDeviation: 7))
            .AddPlayer(player: player4, rating: Rating(mean: 19, standardDeviation: 6))
            .AddPlayer(player: player5, rating: Rating(mean: 30, standardDeviation: 9))
            .AddPlayer(player: player6, rating: Rating(mean: 10, standardDeviation: 4))
    
        let team3 = Team()
            .AddPlayer(player: player7, rating: Rating(mean: 50, standardDeviation: 5))
            .AddPlayer(player: player8, rating: Rating(mean: 30, standardDeviation: 2))
        
        let teams = Teams.Concat(team1, team2, team3)
        
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1, 2, 2)
        
        XCTAssertEqual(40.877, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(3.840, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(45.493, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(2.934, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(19.609, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(6.396, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(18.712, newRatingsWinLose[player4!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(5.625, newRatingsWinLose[player4!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(29.353, newRatingsWinLose[player5!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(7.673, newRatingsWinLose[player5!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(9.872, newRatingsWinLose[player6!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(3.891, newRatingsWinLose[player6!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(48.830, newRatingsWinLose[player7!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.590, newRatingsWinLose[player7!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(29.813, newRatingsWinLose[player8!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(1.976, newRatingsWinLose[player8!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.367, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testThreeTeamsOfOneNotDrawn() {
        let team1 = Team(firstPlayer: player1, playerRating: gameInfo!.DefaultRating)
        let team2 = Team(firstPlayer: player2, playerRating: gameInfo!.DefaultRating)
        let team3 = Team(firstPlayer: player3, playerRating: gameInfo!.DefaultRating)
        
        let teams = Teams.Concat(team1, team2, team3)
        
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1, 2, 3)
        
        XCTAssertEqual(31.675352419172107, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(6.6559853776206905, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(25.000000000003912, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(6.2078966412243233, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(18.324647580823971, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(6.6559853776218318, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.200, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testThreeTeamsOfOneDrawn() {
        let team1 = Team(firstPlayer: player1, playerRating: gameInfo!.DefaultRating)
        let team2 = Team(firstPlayer: player2, playerRating: gameInfo!.DefaultRating)
        let team3 = Team(firstPlayer: player3, playerRating: gameInfo!.DefaultRating)
        
        let teams = Teams.Concat(team1, team2, team3)
        
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1, 1, 1)
        
        XCTAssertEqual(25.000, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(5.698, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(25.000, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(5.698, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(25.000, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(5.698, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.200, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testFourTeamsOfOneNotDrawn() {
        let team1 = Team(firstPlayer: player1, playerRating: gameInfo!.DefaultRating)
        let team2 = Team(firstPlayer: player2, playerRating: gameInfo!.DefaultRating)
        let team3 = Team(firstPlayer: player3, playerRating: gameInfo!.DefaultRating)
        let team4 = Team(firstPlayer: player4, playerRating: gameInfo!.DefaultRating)
        
        let teams = Teams.Concat(team1, team2, team3, team4)
        
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1, 2, 3, 4)
        
        XCTAssertEqual(33.206680965631264, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(6.3481091698077057, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(27.401454693843323, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(5.7871629348447584, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(22.598545306188374, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(5.7871629348413451, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(16.793319034361271, newRatingsWinLose[player4!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(6.3481091698144967, newRatingsWinLose[player4!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.089, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testFiveTeamsOfOneNotDrawn() {
        let team1 = Team(firstPlayer: player1, playerRating: gameInfo!.DefaultRating)
        let team2 = Team(firstPlayer: player2, playerRating: gameInfo!.DefaultRating)
        let team3 = Team(firstPlayer: player3, playerRating: gameInfo!.DefaultRating)
        let team4 = Team(firstPlayer: player4, playerRating: gameInfo!.DefaultRating)
        let team5 = Team(firstPlayer: player5, playerRating: gameInfo!.DefaultRating)
        
        let teams = Teams.Concat(team1, team2, team3, team4, team5)
        
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1, 2, 3, 4, 5)
        
        XCTAssertEqual(34.363135705841188, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(6.1361528798112692, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(29.058448805636779, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(5.5358352402833413, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(25.000000000031758, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(5.4200805474429847, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        XCTAssertEqual(20.941551194426314, newRatingsWinLose[player4!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(5.5358352402709672, newRatingsWinLose[player4!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(15.636864294158848, newRatingsWinLose[player4!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(6.136152879829349, newRatingsWinLose[player4!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.040, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testEightTeamsOfOneDrawn() {
        let team1 = Team(firstPlayer: player1, playerRating: gameInfo!.DefaultRating)
        let team2 = Team(firstPlayer: player2, playerRating: gameInfo!.DefaultRating)
        let team3 = Team(firstPlayer: player3, playerRating: gameInfo!.DefaultRating)
        let team4 = Team(firstPlayer: player4, playerRating: gameInfo!.DefaultRating)
        let team5 = Team(firstPlayer: player5, playerRating: gameInfo!.DefaultRating)
        let team6 = Team(firstPlayer: player6, playerRating: gameInfo!.DefaultRating)
        let team7 = Team(firstPlayer: player7, playerRating: gameInfo!.DefaultRating)
        let team8 = Team(firstPlayer: player8, playerRating: gameInfo!.DefaultRating)
        
        let teams = Teams.Concat(team1, team2, team3, team4, team5, team6, team7, team8)
        
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1, 1, 1, 1, 1, 1, 1, 1)
        
        XCTAssertEqual(25.000, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.592, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(25.000, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.583, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(25.000, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.576, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(25.000, newRatingsWinLose[player4!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.573, newRatingsWinLose[player4!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(25.000, newRatingsWinLose[player5!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.573, newRatingsWinLose[player5!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(25.000, newRatingsWinLose[player6!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.576, newRatingsWinLose[player6!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(25.000, newRatingsWinLose[player7!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.583, newRatingsWinLose[player7!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(25.000, newRatingsWinLose[player8!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.592, newRatingsWinLose[player8!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.004, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testEightTeamsOfOneUpset() {
        let team1 = Team(firstPlayer: player1, playerRating: Rating(mean: 10, standardDeviation: 8))
        let team2 = Team(firstPlayer: player2, playerRating: Rating(mean: 15, standardDeviation: 7))
        let team3 = Team(firstPlayer: player3, playerRating: Rating(mean: 20, standardDeviation: 6))
        let team4 = Team(firstPlayer: player4, playerRating: Rating(mean: 25, standardDeviation: 5))
        let team5 = Team(firstPlayer: player5, playerRating: Rating(mean: 30, standardDeviation: 4))
        let team6 = Team(firstPlayer: player6, playerRating: Rating(mean: 35, standardDeviation: 3))
        let team7 = Team(firstPlayer: player7, playerRating: Rating(mean: 40, standardDeviation: 2))
        let team8 = Team(firstPlayer: player8, playerRating: Rating(mean: 45, standardDeviation: 1))
        
        let teams = Teams.Concat(team1, team2, team3, team4, team5, team6, team7, team8)
        
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1, 2, 3, 4, 5, 6, 7, 8)
        
        XCTAssertEqual(35.135, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.506, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(32.585, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.037, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(31.329, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(3.756, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(30.984, newRatingsWinLose[player4!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(3.453, newRatingsWinLose[player4!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(31.751, newRatingsWinLose[player5!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(3.064, newRatingsWinLose[player5!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(34.051, newRatingsWinLose[player6!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(2.541, newRatingsWinLose[player6!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(38.263, newRatingsWinLose[player7!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(1.849, newRatingsWinLose[player7!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(44.118, newRatingsWinLose[player8!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(0.983, newRatingsWinLose[player8!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(0.000, calculator.CalculateMatchQuality(gameInfo: gameInfo!, teams: teams), accuracy: ErrorTolerance)
    }
    
    func testSixteenTeamsOfOneNotDrawn() {
        let player9 = Player(id: 9)
        let player10 = Player(id: 10)
        let player11 = Player(id: 11)
        let player12 = Player(id: 12)
        let player13 = Player(id: 13)
        let player14 = Player(id: 14)
        let player15 = Player(id: 15)
        let player16 = Player(id: 16)
        
        let team1 = Team(firstPlayer: player1!, playerRating: gameInfo!.DefaultRating)
        let team2 = Team(firstPlayer: player2!, playerRating: gameInfo!.DefaultRating)
        let team3 = Team(firstPlayer: player3!, playerRating: gameInfo!.DefaultRating)
        let team4 = Team(firstPlayer: player4!, playerRating: gameInfo!.DefaultRating)
        let team5 = Team(firstPlayer: player5!, playerRating: gameInfo!.DefaultRating)
        let team6 = Team(firstPlayer: player6!, playerRating: gameInfo!.DefaultRating)
        let team7 = Team(firstPlayer: player7!, playerRating: gameInfo!.DefaultRating)
        let team8 = Team(firstPlayer: player8!, playerRating: gameInfo!.DefaultRating)
        let team9 = Team(firstPlayer: player9, playerRating: gameInfo!.DefaultRating)
        let team10 = Team(firstPlayer: player10, playerRating: gameInfo!.DefaultRating)
        let team11 = Team(firstPlayer: player11, playerRating: gameInfo!.DefaultRating)
        let team12 = Team(firstPlayer: player12, playerRating: gameInfo!.DefaultRating)
        let team13 = Team(firstPlayer: player13, playerRating: gameInfo!.DefaultRating)
        let team14 = Team(firstPlayer: player14, playerRating: gameInfo!.DefaultRating)
        let team15 = Team(firstPlayer: player15, playerRating: gameInfo!.DefaultRating)
        let team16 = Team(firstPlayer: player16, playerRating: gameInfo!.DefaultRating)
        
        let teams = Teams.Concat(team1, team2, team3, team4, team5,
                                 team6, team7, team8, team9, team10,
                                 team11, team12, team13, team14, team15,
                                 team16)
        
        let newRatingsWinLose = calculator.CalculateNewRatings(gameInfo: gameInfo!, teams: teams, teamRanks: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
        
        
        XCTAssertEqual(40.53945776946920, newRatingsWinLose[player1!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(5.27581643889050, newRatingsWinLose[player1!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(36.80951229454210, newRatingsWinLose[player2!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.71121217610266, newRatingsWinLose[player2!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(34.34726355544460, newRatingsWinLose[player3!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.52440328139991, newRatingsWinLose[player3!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(32.33614722608720, newRatingsWinLose[player4!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.43258628279632, newRatingsWinLose[player4!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(30.55048814671730, newRatingsWinLose[player5!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.38010805034365, newRatingsWinLose[player5!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(28.89277312234790, newRatingsWinLose[player6!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.34859291776483, newRatingsWinLose[player6!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(27.30952161972210, newRatingsWinLose[player7!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.33037679041216, newRatingsWinLose[player7!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(25.76571046519540, newRatingsWinLose[player8!]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.32197078088701, newRatingsWinLose[player8!]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(24.23428953480470, newRatingsWinLose[player9]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.32197078088703, newRatingsWinLose[player9]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(22.69047838027800, newRatingsWinLose[player10]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.33037679041219, newRatingsWinLose[player10]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(21.10722687765220, newRatingsWinLose[player11]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.34859291776488, newRatingsWinLose[player11]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(19.44951185328290, newRatingsWinLose[player12]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.38010805034375, newRatingsWinLose[player12]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(17.66385277391300, newRatingsWinLose[player13]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.43258628279643, newRatingsWinLose[player13]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(15.65273644455550, newRatingsWinLose[player14]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.52440328139996, newRatingsWinLose[player14]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(13.19048770545810, newRatingsWinLose[player15]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(4.71121217610273, newRatingsWinLose[player15]!.StandardDeviation, accuracy: ErrorTolerance)
        
        XCTAssertEqual(9.46054223053080, newRatingsWinLose[player16]!.Mean, accuracy: ErrorTolerance)
        XCTAssertEqual(5.27581643889032, newRatingsWinLose[player16]!.StandardDeviation, accuracy: ErrorTolerance)
    }
    
    func testOneOnTwoBalancedPartialPlay() {
        let gameInfo = GameInfo.DefaultGameInfo
        let p1 = Player(id: 1)
        let team1 = Team(firstPlayer: p1, playerRating: gameInfo.DefaultRating)
        
        let p2 = Player(id: 2)
        let p3 = Player(id: 3)
        
        let team2 = Team().AddPlayer(player: p2, rating: Rating(mean: 2, standardDeviation: 0.0)).AddPlayer(player: p3, rating: Rating(mean: 3, standardDeviation: 1.00))
        
        let teams = Teams.Concat(team1, team2)
        
        //let newRatings = calculator.CalculateNewRatings(gameInfo: gameInfo, teams: teams, teamRanks: 1,2)
        //let matchQuality = calculator.CalculateMatchQuality(gameInfo: gameInfo, teams: teams)
    }
}
