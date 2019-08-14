//
//  DatabaseManager.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/14/19.
//  Copyright © 2019 Milan Vidovic. All rights reserved.
//

import Foundation
import SQLite

class DatabaseManager {
    
    //MARK tables
    let user_table = Table("user")
    
    
    //MARK fields
    let userId = Expression<Int64>("userId")
    let age = Expression<Int64>("age")
    let gender = Expression<String>("gender")
    let dateOfBirdth = Expression<Date>("dateOfBirdth")
    let height = Expression<Int64>("height")
    let weight = Expression<Int64>("weight")
    
    private let db: Connection?
    
    static let instance = DatabaseManager()
    
    
    private init() {
        Swift.print("DatabaseManager init")
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            db = try Connection("\(path)/db.sqlite3")
        } catch  {
            db = nil
            Swift.print("DatabaseManager init error! \(error)")
        }
        createTables()
    }
    
    private func createTables(){
        createUserTable()
    }
    
    private func createUserTable(){
        do{
            try db!.run(user_table.create(ifNotExists: true) { t in   // CREATE TABLE IF NOT EXIST "user" (
                t.column(userId, primaryKey: .autoincrement)          //  "userId" INTEGER PRIMARY KEY NOT NULL,
                t.column(age)                                         //  "age" INT,
                t.column(gender)                                      //  "gender" TEXT,
                t.column(dateOfBirdth)                                //  "dateOfBirdth" DATE,
                t.column(height)                                      //  "height" DOUBLE,
                t.column(weight)                                      //  "weight" DOUBLE
            })
        } catch  {
            Swift.print("createTableUser error! \(error)")
        }
    }
    
    
    
    public func insertOrUpdateUser(user : UserProfile) -> Bool{
        var value = false
       
        do {
            let insert = user_table.insert(self.age <- Int64(user.age!),
                                           self.gender <- user.gender!,
                                           self.dateOfBirdth <- user.dateOfBirth!,
                                           self.weight <- Int64(user.weight!),
                                           self.height <- Int64(user.height!))
            try self.db!.run(user_table.delete())
            try self.db!.run(insert)
            value = true
        } catch {
            Swift.print("insertUser  \(error)")
            
        }
        return value
    }
    
    public func selectUser() -> UserProfile? {
        var user : UserProfile? = nil
        do {
            for row in try db!.prepare(user_table) {
                user = UserProfile(Int(row[age]), row[gender], row[dateOfBirdth], Int(row[height]), Int(row[weight]))
            }
        } catch {
            Swift.print("selectUsers failed  \(error)")
        }
        return user
    }
}
