//
//  RankSorter.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 7/6/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

//enum RankSorterError: Error {
//    case teamsNull
//    case teamRanksNull
//}

internal class RankSorter {
    public static func Sort<T: Hashable>(teams: [T], teamRanks: [Int]) -> ([T], [Int]) {
        
//        guard let teams = teams else {
//            throw RankSorterError.teamsNull
//        }
//        guard let teamRanks = teamRanks else {
//            throw RankSorterError.teamRanksNull
//        }

        var lastObservedRank = 0
        var needToSort = false

        for currentRank in teamRanks {
            if currentRank < lastObservedRank {
                needToSort = true
                break
            }
            lastObservedRank = currentRank
        }


        if !needToSort {
            return (teams, teamRanks)
        }

        var itemToRank: [T: Int] = [:]
        
        for i in 0..<teams.count {
            let currentItem = teams[i]
            let currentItemRank = teamRanks[i]
            itemToRank[currentItem] = currentItemRank // key is team, value is teamRank
        }

        var sortedItems: [T] = []
        var sortedRanks: [Int] = []

        for (key, value) in itemToRank.sorted(by: { $0.1 < $1.1 }) {
            sortedItems.append(key)
            sortedRanks.append(value)
        }
        
        return (sortedItems, sortedRanks)
    }
    
}

