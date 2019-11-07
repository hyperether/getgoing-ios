//
//  LocationManager.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/13/19.
//  Copyright © 2019 Hyperether LLC. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

protocol LocationManagerDelegate : AnyObject {
    func locationManagerFoundNewLocation(_ difference : Double,_ polyline: MKPolyline,_ speed: Double)
}

class LocationManager : NSObject {
    
    static let shared = LocationManager()
    
    var clManager = CLLocationManager()
    var clStatus : CLAuthorizationStatus?
    var upperSpeedBound = 4.0
    var delegate : LocationManagerDelegate?
    
    var averageSpeed = 0.0
    
    var locationList : [CLLocation] = []
    var possibleLocation : CLLocation?
    var possibleLocationTimeDifference = 0.0
    
    private override init(){
        super.init()
        configureLocationManager()
    }
    
    func configureLocationManager(){
        clManager.desiredAccuracy = kCLLocationAccuracyBest
        clManager.activityType = .fitness
        clManager.distanceFilter = 10
        clManager.delegate = self
        clManager.requestAlwaysAuthorization()
        clManager.allowsBackgroundLocationUpdates = true
    }
    
    func resetLocationManager(){
        locationList = []
        possibleLocation = nil
        possibleLocationTimeDifference = 0.0
        averageSpeed = 0.0
    }
    
    func addRoute(){
        Activities.shared.listOfRoutes.append(locationList)
    }
    
}

extension LocationManager : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        clStatus = status
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            clManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            if (newLocation.horizontalAccuracy > 20 || abs(howRecent) > 10){
                continue
            }
            if let lastLocation = locationList.last{
                
                let timeDifference = abs(newLocation.timestamp.timeIntervalSinceNow - lastLocation.timestamp.timeIntervalSinceNow)
                let difference = newLocation.distance(from: lastLocation)
                //print("checking new speed")
                let checkNewLocation = checkSpeed(difference/timeDifference)
                
                let area = [lastLocation.coordinate,newLocation.coordinate]
                let polyline = MKPolyline(coordinates: area, count: area.count)
                
                if (checkNewLocation.check){
                    //print("checked new location")
                    delegate?.locationManagerFoundNewLocation(difference, polyline, difference/timeDifference)
                    calculateAverageSpeed(difference/timeDifference)
                    possibleLocation = nil
                    locationList.append(newLocation)
                } else {
                    if (possibleLocation != nil){
                        
                        let possibleTimeDifference = possibleLocationTimeDifference
                        let possibleDifference = lastLocation.distance(from: possibleLocation!)
                        
                        let possibleArea = [lastLocation.coordinate,possibleLocation!.coordinate]
                        let possiblePolyline = MKPolyline(coordinates: possibleArea, count: possibleArea.count)
                        //print("possible speed: \(possibleDifference/possibleTimeDifference)")
                   
                        //print("checking possible speed")
                        let checkPossibleLocation = checkSpeed(possibleDifference/possibleTimeDifference)
                        if (checkNewLocation.error <= checkPossibleLocation.error){
                            //print("checked new location better than possible")
                            delegate?.locationManagerFoundNewLocation(difference, polyline, difference/timeDifference)
                            calculateAverageSpeed(difference/timeDifference)
                            locationList.append(newLocation)
                        } else {
                            //print("checked possible location better than new")
                            delegate?.locationManagerFoundNewLocation(possibleDifference, possiblePolyline, possibleDifference/possibleTimeDifference)
                            calculateAverageSpeed(possibleTimeDifference/possibleTimeDifference)
                            locationList.append(possibleLocation!)
                        }
                        possibleLocation = nil
                        possibleLocationTimeDifference = 0.0
                    } else {
                        possibleLocation = newLocation
                        possibleLocationTimeDifference = timeDifference
                    }
                }
                
            } else {
                locationList.append(newLocation)
            }
            
        }
    }
    
    func calculateAverageSpeed(_ differenceSpeed : Double){
        if (averageSpeed == 0.0){
            averageSpeed = differenceSpeed
        } else {
            averageSpeed = (averageSpeed + differenceSpeed)/2
        }
    }
    
    func checkSpeed(_ speed : Double) -> (check: Bool,error: Double){
        var check = true
        var error = 0.0
        //print("speed : \(speed)")
        if (speed > upperSpeedBound){
            check = false
            error = speed - upperSpeedBound
        }
        return (check,error)
    }
    
    
    
}
