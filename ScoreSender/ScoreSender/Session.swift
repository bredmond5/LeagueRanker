//
//  Session.swift
//  ScoreSender
//
//  Created by Brice Redmond on 4/9/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation
import FirebaseAuth

//func listen() {
//    _ = Auth.auth().addStateDidChangeListener { (auth, user) in
//        if let user = user {
//            self.session = User(uid: user.uid, displayName: user.displayName, email: user.email)
//        }
//    }
//}
//
//func logIn(email: String, password: String, handler: @escaping AuthDataResultCallback) {
//    Auth.auth().signIn(withEmail: email, password: password, completion: handler)
//}
//
//func logOut() {
//        try! Auth.auth().signOut()
//}
//
//func signUp(email: String, password: String, handler: @escaping AuthDataResultCallback) {
//    Auth.auth().createUser(withEmail: email, password: password, completion: handler)
//}
//
//func getTODOS() {
//    ref.observe(DataEventType.value) { (snapshot) in
//        self.items = []
//        for child in snapshot.children {
//            if let snapshot = child as? DataSnapshot,
//                let toDo = TODOS(snapshot: snapshot) {
//                self.items.append(toDo)
//            }
//        }
//    }
//}
//
//func uploadTODO(todo: String) {
//    //Generates number going up as time goes on, sets order of TODO's by how old they are.
//    let number = Int(Date.timeIntervalSinceReferenceDate * 1000)
//    
//    let postRef = ref.child(String(number))
//    let post = TODOS(todo: todo, isComplete: "false")
//    postRef.setValue(post.toAnyObject())
//}
//
//func updateTODO(key: String, todo: String, isComplete: String) {
//    let update = ["todo": todo, "isComplete": isComplete]
//    let childUpdate = ["\(key)": update]
//    ref.updateChildValues(childUpdate)
//}
