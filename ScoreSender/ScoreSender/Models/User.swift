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
    @Published var realName: String? // this will be the users real name
    @Published var image: UIImage
    var leagueNames: [String]
    
    init(uid: String, realName: String?, phoneNumber: String?, image: UIImage = Constants.defaultPlayerPhoto, leagueNames: [String])
    {
        self.uid = uid
        self.realName = realName
        self.phoneNumber = phoneNumber
        self.image = image
        self.leagueNames = leagueNames
    }
}
