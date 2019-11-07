//
//  Run.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/6/19.
//  Copyright © 2019 Hyperether LLC. All rights reserved.
//

import Foundation
import MapKit

class Run : NSObject {
    
    var id : Int64?
    var date : Date?
    var distance : Float?
    var route : [MKOverlay]?
    var style : String?
    var timeInSeconds : Int?
    var calories : Int?
    var averageSpeed : Float?
    var goal : Goal?
    
    var listOfRouteParts : [[CLLocation]]?
    
    init(_ date : Date, _ distance : Float, _ style : String,_ timeInSeconds: Int,_ calories : Int, _ averageSpeed : Float, _ goal : Goal,_ listOfLocations : [[CLLocation]]){
        super.init()
        self.date = date
        self.distance = distance
        self.route = makeFullRoute(listOfRoutes: listOfLocations)
        self.style = style
        self.timeInSeconds = timeInSeconds
        self.calories = calories
        self.averageSpeed = averageSpeed
        self.goal = goal
        self.listOfRouteParts = listOfLocations
    }
    
    private func makeFullRoute(listOfRoutes : [[CLLocation]]) -> [MKOverlay]? {
        guard listOfRoutes.count > 0 else {
            return nil
        }
        var fullRoute : [MKOverlay] = []
        for locationRoute in listOfRoutes{
            if let route = makeRouteWithLocations(listOfLocations: locationRoute) {
                for routePart in route {
                    fullRoute.append(routePart)
                }
            }
        }
        if (fullRoute.count == 0){
            return nil
        } else {
            return fullRoute
        }
    }
    
    private func makeRouteWithLocations(listOfLocations : [CLLocation]) -> [MKOverlay]?{
        guard listOfLocations.count > 1 else {
            return nil
        }
        var route : [MKOverlay] = []
        var first = listOfLocations.first!
        
        for location in listOfLocations{
            if (first != location){
                let area = [first.coordinate,location.coordinate]
                let polyline = MKPolyline(coordinates: area, count: area.count)
                route.append(polyline)
                first = location
            }
        }
        
        if (route.count == 0){
            return nil
        } else {
            return route
        }
    }
}
