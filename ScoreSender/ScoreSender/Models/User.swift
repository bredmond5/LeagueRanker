//
//  User.swift
//  TODO
//
//  Created by Sebastian Esser on 9/18/19.
//  Copyright © 2019 Sebastian Esser. All rights reserved.
//

import SwiftUI
import FirebaseDatabase

class User: Identifiable {
    
    var uid: String
    var phoneNumber: String?
    @Published var realName: String? // this will be the users real name
    @Published var dbImage: DBImage
    var leagueNames: [String]
    
    init(uid: String, realName: String?, phoneNumber: String?, leagueNames: [String])
    {
        self.uid = uid
        self.realName = realName
        self.phoneNumber = phoneNumber
        self.leagueNames = leagueNames
        self.dbImage = DBImage(defaultImage: Constants.defaultPlayerPhoto, dateRef: Database.database().reference(withPath: "users/\(uid)/icDate"), storagePath: "\(uid).jpg")
    }
    
    func change(image: UIImage) {
        self.dbImage.handle(newImage: image)
    }
}
