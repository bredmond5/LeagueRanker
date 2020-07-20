//
//  main.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 4/26/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

let gameInfo = GameInfo.DefaultGameInfo

var player1 = Player(id: 1)
var player2 = Player(id: 2)
var player3 = Player(id: 3)
var player4 = Player(id: 4)

let team1 = Team().AddPlayer(player: player1, rating: gameInfo.DefaultRating).AddPlayer(player: player2, rating: gameInfo.DefaultRating)
let team2 = Team().AddPlayer(player: player3, rating: gameInfo.DefaultRating).AddPlayer(player: player4, rating: gameInfo.DefaultRating)

let teams = Teams.Concat(team1, team2)

let newRatings = TrueSkillCalculator.CalculateNewRatings(gameInfo: gameInfo, teams: teams, teamRanks: 1,2)

let player1NewRating = newRatings[player1]
print(player1NewRating!.Mean)
