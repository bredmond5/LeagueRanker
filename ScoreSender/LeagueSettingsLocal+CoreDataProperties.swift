//
//  LeagueSettingsLocal+CoreDataProperties.swift
//  
//
//  Created by Brice Redmond on 9/14/20.
//
//

import Foundation
import CoreData


extension LeagueSettingsLocal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LeagueSettingsLocal> {
        return NSFetchRequest<LeagueSettingsLocal>(entityName: "LeagueSettingsLocal")
    }

    @NSManaged public var numPlacements: Int64
    @NSManaged public var playersPerTeam: Int64
    @NSManaged public var ownerUID: String
    @NSManaged public var dateLastOpened: Int64
    @NSManaged public var image: Data
    @NSManaged public var name: String
    @NSManaged public var imageChangeDate: Int64
    @NSManaged public var leagueLocal: LeagueLocal

}
