//
//  Run.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/6/19.
//  Copyright © 2019 Milan Vidovic. All rights reserved.
//

import Foundation
import MapKit

class Run : NSObject {
    var date : Date?
    var distance : Float?
    var route : [MKOverlay]?
    var style : String?
    var timeInSeconds : Int?
    var calories : Int?
    var averageSpeed : Float?
    var goal : Goal?
    
    init(_ date : Date, _ distance : Float, _ route : [MKOverlay], _ style : String,_ timeInSeconds: Int,_ calories : Int, _ averageSpeed : Float, _ goal : Goal){
        super.init()
        self.date = date
        self.distance = distance
        self.route = route
        self.style = style
        self.timeInSeconds = timeInSeconds
        self.calories = calories
        self.averageSpeed = averageSpeed
        self.goal = goal
    }
}
