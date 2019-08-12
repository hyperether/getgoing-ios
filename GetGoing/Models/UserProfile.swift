//
//  UserProfile.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/6/19.
//  Copyright © 2019 Milan Vidovic. All rights reserved.
//

import Foundation
import SQLite

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
    
    func saveToDB(){
        let user = Table("user")
        let userId = Expression<Int64>("userId")
        let age = Expression<Int64>("age")
        let gender = Expression<String>("gender")
        let dateOfBirdth = Expression<Date>("dateOfBirdth")
        let height = Expression<Int64>("height")
        let weight = Expression<Int64>("weight")
        let insert = user.insert(age <- Int64(self.age!),gender <- (self.gender!), dateOfBirdth <- (self.dateOfBirth!), height <- Int64(self.height!), weight <- Int64(self.weight!))
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
         //   try db.run(user.drop(ifExists: true))
            try db.run(user.create(ifNotExists: true){ t in
                t.column(userId, primaryKey: true)
                t.column(age)
                t.column(gender)
                t.column(dateOfBirdth)
                t.column(height)
                t.column(weight)
            })
            try db.run(user.delete())
            try db.run(insert)
        } catch  {
            print("error from save")
            print(Error.self)
        }
    }
    
    func loadFromDB(){
        let age = Expression<Int64>("age")
        let gender = Expression<String>("gender")
        let dateOfBirdth = Expression<Date>("dateOfBirdth")
        let height = Expression<Int64>("height")
        let weight = Expression<Int64>("weight")

        let userT = Table("user")
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            let db = try Connection("\(path)/db.sqlite3")
            for user in try db.prepare(userT) {
                self.age = Int(user[age])
                self.gender = user[gender]
                self.dateOfBirth = user[dateOfBirdth]
                self.height = Int(user[height])
                self.weight = Int(user[weight])
            }
        } catch {
            print("error from load")
            print(Error.self)
        }
    }
    
    
}
