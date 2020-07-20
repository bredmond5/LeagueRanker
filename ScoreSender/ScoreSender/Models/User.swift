//
//  User.swift
//  TODO
//
//  Created by Sebastian Esser on 9/18/19.
//  Copyright © 2019 Sebastian Esser. All rights reserved.
//

import SwiftUI

class User: Identifiable {
    
    var uid: String
    var phoneNumber: String?
    var displayName: String?
    @State var image: UIImage
    var leagueNames: [String]
    
    init(uid: String, displayName: String?, phoneNumber: String?, image: UIImage = UIImage(), leagueNames: [String])
    {
        self.uid = uid
        self.displayName = displayName
        self.phoneNumber = phoneNumber
        self.image = image
        self.leagueNames = leagueNames
    }
}
