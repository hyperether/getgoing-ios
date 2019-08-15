//
//  Activities.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/6/19.
//  Copyright © 2019 Milan Vidovic. All rights reserved.
//

import Foundation
import CoreLocation

class Activities : NSObject {
    
    static var shared = Activities.init()
    var listOfRuns : [Run] = []
    var currentGoal : Goal?
    var walkingDataEntries : [DataEntry] = []
    var runningDataEntries : [DataEntry] = []
    var bicyclingDataEntries : [DataEntry] = []
    
    var serverIdCounter = 0
    
    //route info
    var listOfRoutes : [[CLLocation]] = []
    
    private override init() {
        super.init()
    }
    
}
