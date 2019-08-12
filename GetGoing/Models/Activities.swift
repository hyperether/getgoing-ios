//
//  Activities.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/6/19.
//  Copyright © 2019 Milan Vidovic. All rights reserved.
//

import Foundation

class Activities : NSObject {
    
    static var shared = Activities.init()
    var listOfRuns : [Run] = []
    var walkingDistance : Float?
    var runningDistance : Float?
    var bicyclingDistance : Float?
    var currentGoal : Goal?
    
    private override init() {
        super.init()
    }

    
}
