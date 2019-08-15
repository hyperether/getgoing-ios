//
//  DatabaseManager.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/14/19.
//  Copyright © 2019 Milan Vidovic. All rights reserved.
//

import Foundation
import SQLite
import CoreLocation

class DatabaseManager {
    
    //MARK tables
    let user_table = Table("user")
    let run_table = Table("run")
    let route_table = Table("route")
    let route_part_table = Table("routePart")
    
    //MARK field
    let serverId = Expression<String>("serverId")
    let id = Expression<Int64>("id")
    
    //MARK user fields
    let userId = Expression<Int64>("userId")
    let age = Expression<Int64>("age")
    let gender = Expression<String>("gender")
    let dateOfBirdth = Expression<Date>("dateOfBirdth")
    let height = Expression<Int64>("height")
    let weight = Expression<Int64>("weight")
    
    //MARK run fields
    let runId = Expression<Int64>("runId")
    let runDate = Expression<Date>("runDate")
    let runDistance = Expression<Double>("runDistance")
    let runCalories = Expression<Int64>("runCalories")
    let runStyle = Expression<String>("runStyle")
    let runTime = Expression<Int64>("runTime")
    let runSpeed = Expression<Double>("runSpeed")
    let runGoalDistance = Expression<Double>("runGoalDistance")
    
    //MARK route fields
    let routeId = Expression<Int64>("routeId")
    
    //MARK route part fields
    let routePartId = Expression<String>("routePartId")
    let lon = Expression<Double>("lon")
    let lat = Expression<Double>("lat")
    
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
        createRunTable()
        createRouteTable()
        createRoutePartTable()
    }
    
    private func createUserTable(){
        do{
            try db!.run(user_table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(serverId, unique:true, collate: .rtrim)
                t.column(age)
                t.column(gender)
                t.column(dateOfBirdth)
                t.column(height)
                t.column(weight)
            })
        } catch  {
            Swift.print("createUserTable error! \(error)")
        }
    }
    
    private func createRunTable(){
        do{
            try db!.run(run_table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(runStyle)
                t.column(runDate)
                t.column(runDistance)
                t.column(runCalories)
                t.column(runSpeed)
                t.column(runTime)
                t.column(runGoalDistance)
            })
        } catch  {
            Swift.print("createRunTable error! \(error)")
        }
    }
    
    private func createRoutePartTable(){
        do{
            try db!.run(route_part_table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(routeId)
                t.column(lon)
                t.column(lat)
            })
        } catch  {
            Swift.print("createRoutePartTable error! \(error)")
        }
    }
    
    private func createRouteTable(){
        do{
            try db!.run(route_table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(runId)
            })
        } catch  {
            Swift.print("createRouteTable error! \(error)")
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
    
    public func insertRun(run : Run){
            do {
                let insert = run_table.insert(self.runStyle <- run.style!,
                                               self.runDate <- run.date!,
                                               self.runSpeed <- Double(run.averageSpeed!),
                                               self.runCalories <- Int64(run.calories!),
                                               self.runTime <- Int64(run.timeInSeconds!),
                                               self.runDistance <- Double(run.distance!),
                                               self.runGoalDistance <- Double(run.goal!.distance!))
                let id = try self.db!.run(insert)
                run.id = id
            } catch {
                Swift.print("insertRun  \(error)")
                
            }
        
    }
    
    public func insertRoute(run : Run) -> Int64?{
        var routeId : Int64? = nil
        do {
            let insert = route_table.insert(self.runId <- run.id!)
            
            routeId = try self.db!.run(insert)
        } catch {
            Swift.print("insertRoute  \(error)")
            
        }
        return routeId
    }
    
    public func insertRoutePart(lon : Double, lat : Double, routeId : Int64){
        do {
            let insert = route_part_table.insert(self.routeId <- routeId,
                                            self.lon <- lon,
                                            self.lat <- lat)
            
            try self.db!.run(insert)
        } catch {
            Swift.print("insertRoutePart  \(error)")
            
        }
    }
    
    func saveRunToDb(run : Run){
        insertRun(run: run)
        for route in run.listOfRouteParts!{
            guard let routeId = insertRoute(run: run) else {
                break
            }
            for routePart in route{
                insertRoutePart(lon: routePart.coordinate.longitude, lat: routePart.coordinate.latitude,routeId: routeId)
            }
        }
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
    
    public func selectRoutePart(serverIdValue : Int64) -> [CLLocation]? {
        var list : [CLLocation] = []
        do {
            for routePart in try db!.prepare(route_part_table.filter(routeId==serverIdValue)) {
                list.append(CLLocation.init(latitude: routePart[lat], longitude: routePart[lon]))
            }
        } catch {
            Swift.print("selectRoutePart failed  \(error)")
        }
        if (list.count > 0){
            return list
        } else {
            return nil
        }
    }
    
    public func selectRuns()-> [Run]?{
        var list : [Run] = []
        do {
            for runRow in try db!.prepare(run_table) {
                if let locationList = selectRoute(serverIdValue: runRow[id]){
                    list.append(Run(runRow[runDate], Float(runRow[runDistance]), runRow[runStyle], Int(runRow[runTime]), Int(runRow[runCalories]), Float(runRow[runSpeed]), Goal.init(distance: Float(runRow[runGoalDistance])), locationList))
                }
                
            }
        } catch {
            Swift.print("selectRuns failed  \(error)")
        }
        if (list.count > 0){
            return list
        } else {
            return nil
        }
    }
    
    public func selectRoute(serverIdValue : Int64) -> [[CLLocation]]?{
        var list : [[CLLocation]] = []
        do {
            for route in try db!.prepare(route_table.filter(runId==serverIdValue)) {
                if let data = selectRoutePart(serverIdValue: route[id]){
                    list.append(data)
                }
            }
        } catch {
            Swift.print("selectRoute failed  \(error)")
        }
        if (list.count > 0){
            return list
        } else {
            return nil
        }
    }
    
}
