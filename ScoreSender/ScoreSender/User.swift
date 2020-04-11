//
//  User.swift
//  ScoreSender
//
//  Created by Brice Redmond on 4/9/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation
import SwiftUI

class User {
    
    let uid: UUID
    var displayName: String
    var image: UIImage?
    
    init(uid: UUID, displayName: String, image: UIImage?) {
        self.uid = uid
        self.displayName = displayName
        self.image = image
    }
}
