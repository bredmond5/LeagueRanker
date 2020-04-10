//
//  User.swift
//  ScoreSender
//
//  Created by Brice Redmond on 4/9/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

class User {
    
    var uid: String
    var displayName: String?
    
    init(uid: String, displayName: String?) {
        self.uid = uid
        self.displayName = displayName
    }
}
