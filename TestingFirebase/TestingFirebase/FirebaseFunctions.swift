//
//  FirebaseFunctions.swift
//  TestingFirebase
//
//  Created by Brice Redmond on 5/10/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseFunctions {
    var ref: DatabaseReference!

    init() {
        ref = Database.database().reference()
    }
    
    func addUser(_ username: String, uid: UUID) {
        self.ref.child("users/\(uid)/username").setValue(username)
    }
    
}
