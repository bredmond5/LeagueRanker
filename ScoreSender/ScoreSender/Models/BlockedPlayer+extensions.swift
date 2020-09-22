//
//  BlockedPlayer+extensions.swift
//  ScoreSender
//
//  Created by Brice Redmond on 9/14/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

extension BlockedPlayer {
    func toAnyObject() -> Any {
        return [
            "displayName" : displayName,
            "realName" : realName,
            "uid" : id,
            "phoneNumber" : phoneNumber,
        ] as Any
    }
    
    func setValues(to arr: NSArray, id: String?) {
        self.displayName = arr[0] as? String
        self.realName = arr[2] as? String
        self.phoneNumber = arr[1] as? String
        self.id = id as? String
    }
}
