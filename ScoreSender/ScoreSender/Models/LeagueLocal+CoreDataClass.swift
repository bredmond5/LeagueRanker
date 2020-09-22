//
//  LeagueLocal+CoreDataClass.swift
//  
//
//  Created by Brice Redmond on 9/13/20.
//
//

import Foundation
import CoreData
import SwiftUI

@objc(LeagueLocal)
public class LeagueLocal: NSManagedObject {

    @Published public var leagueGames: [Game] = []
    
    
}
