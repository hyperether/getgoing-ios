//
//  UserProfile.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/6/19.
//  Copyright © 2019 Milan Vidovic. All rights reserved.
//

import Foundation

class UserProfile : NSObject {
    
    var age : Int?
    var gender : String?
    var dateOfBirth : Date?
    var height : Int?
    var weight : Int?
    var calories : Int?
    var totalDistance : Float?
    
    init(_ age : Int?, _ gender : String?, _ dateOfBirth : Date?, _ height : Int?, _ weight : Int?){
        super.init()
        self.age = age
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.height = height
        self.weight = weight
        self.calories = 0
        self.totalDistance = 0.0
    }
    
    
}
