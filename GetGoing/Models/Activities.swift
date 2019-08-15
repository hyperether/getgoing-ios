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
    
    
    var walkingRuns : [Run] = []
    var runningRuns : [Run] = []
    var bicyclingRuns : [Run] = []
    
    
    //route info
    var listOfRoutes : [[CLLocation]] = []
    
    private override init() {
        super.init()
    }
    
    func configureRunStylesTables(){
        walkingRuns = []
        runningRuns = []
        bicyclingRuns = []
        for run in listOfRuns{
            switch run.style!{
            case "walking":
                walkingRuns.append(run)
            case "running":
                runningRuns.append(run)
            case "bicycling":
                bicyclingRuns.append(run)
            default:
                break
            }
        }
        
    }
    
    func returnRunsWithStyle(style : String) -> [Run]{
        switch style{
        case "walking":
            return walkingRuns
        case "running":
            return runningRuns
        case "bicycling":
            return bicyclingRuns
        default:
            return []
        }
    }
    
    func addRunToLists(run : Run){
        listOfRuns.append(run)
        listOfRoutes = []
        switch run.style!{
        case "walking":
            walkingRuns.append(run)
        case "running":
            runningRuns.append(run)
        case "bicycling":
            bicyclingRuns.append(run)
        default:
            break
        }
    }
    
    func removeRun(runToDelete: Run){
        let style = runToDelete.style!
        
        switch style {
        case "walking":
            for (i,run) in Activities.shared.walkingRuns.enumerated(){
                if (runToDelete === run){
                    Activities.shared.walkingRuns.remove(at: i)
                }
            }
        case "running":
            for (i,run) in Activities.shared.runningRuns.enumerated(){
                if (runToDelete === run){
                    Activities.shared.runningRuns.remove(at: i)
                }
            }
        case "bicycling":
            for (i,run) in Activities.shared.bicyclingRuns.enumerated(){
                if (runToDelete === run){
                    Activities.shared.bicyclingRuns.remove(at: i)
                }
            }
        default:
            break
        }
        
        for (i,run) in Activities.shared.listOfRuns.enumerated(){
            if (runToDelete === run){
                Activities.shared.listOfRuns.remove(at: i)
            }
        }
    }
    
}
