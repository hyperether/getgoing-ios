//
//  Activities.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/6/19.
//  Copyright © 2019 Milan Vidovic. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class Activities : NSObject {
    
    static var shared = Activities.init()
    var listOfRuns : [Run] = []
    var currentGoal : Goal?
    var walkingDataEntries : [DataEntry] = []
    var runningDataEntries : [DataEntry] = []
    var bicyclingDataEntries : [DataEntry] = []
    
    
    //route info
    var listOfRoutes : [[CLLocation]] = []
    
    private override init() {
        super.init()
    }
    
    public func getDataEntries(style: String) -> [DataEntry]{
        var list : [DataEntry] = []
        for run in listOfRuns {
            if (run.style! == style){
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d.MM"
                let todayDateString = dateFormatter.string(from: run.date!)
                
                let maxDistance = run.goal!.distance!
                let runDistance = run.distance! * 100 / maxDistance
                
                
                if (runDistance > maxDistance){
                    list.append(DataEntry(color: UIColor.init(named: "lightBlue")!, height: 1, textValue: "", title: todayDateString))
                } else {
                    list.append(DataEntry(color: UIColor.init(named: "lightBlue")!, height: runDistance/100, textValue: "", title: todayDateString))
                }
            }
        }
        return list
    }
    
}
