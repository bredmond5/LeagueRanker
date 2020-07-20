//
//  Person.swift
//  TrueskillSwift
//
//  Created by Brice Redmond on 4/26/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import Foundation

public class Person {
    
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    func getAge() -> Int{
        return age
    }
    
    func getName() -> String {
        return name
    }
    
}
