//
//  Goal.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/7/19.
//  Copyright © 2019 Milan Vidovic. All rights reserved.
//

import Foundation

class Goal : NSObject {
    
    var distance : Float?
    var calories : Int?
    var difficulty : String?
    var walkingTime : Int?
    var runningTime : Int?
    var bicyclingTime : Int?
    
    override init() {
        super.init()
    }
    
    init(_ distance : Float,_ calories : Int,_ difficulty : String,_ walkingTime : Int, _ runningTime : Int, _ bicyclingTime : Int){
        self.distance = distance
        self.calories = calories
        self.difficulty = difficulty
        self.walkingTime = walkingTime
        self.runningTime = runningTime
        self.bicyclingTime = bicyclingTime
    }
    
    init(distance : Float) {
        self.distance = distance
        self.calories = Int(distance)/10
        self.difficulty = "low"
        self.walkingTime = Int(distance)/50
        self.runningTime = Int(distance)/70
        self.bicyclingTime = Int(distance)/100
    }
    
}
