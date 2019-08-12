//
//  ActivitiesVC.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/5/19.
//  Copyright © 2019 Milan Vidovic. All rights reserved.
//

import UIKit

protocol ActivitiesVCDelegate : AnyObject {
    func activitiesVCDidSaveGoal()
}

class ActivitiesVC : UIViewController {
    
    @IBOutlet weak var walkingProgressView: UIProgressView!
    @IBOutlet weak var runningProgressView: UIProgressView!
    @IBOutlet weak var bicyclingProgressView: UIProgressView!
    
    
    //goal info display
    @IBOutlet weak var goalDistanceLabel: UILabel!
    @IBOutlet weak var goalCaloriesLabel: UILabel!
    
    @IBOutlet weak var goalSlider: UISlider!
    
    @IBOutlet weak var goalLowLabel: UILabel!
    @IBOutlet weak var goalMediumLabel: UILabel!
    @IBOutlet weak var goalHighLabel: UILabel!

    @IBOutlet weak var goalWalkingLabel: UILabel!
    @IBOutlet weak var goalRunningLabel: UILabel!
    @IBOutlet weak var goalBicycling: UILabel!
    
    //style label
    @IBOutlet weak var walkingLabel: UILabel!
    @IBOutlet weak var runningLabel: UILabel!
    @IBOutlet weak var bicyclingLabel: UILabel!
    
    
    var delegate : ActivitiesVCDelegate?
    var difficulty : String? = "low"
    
    //border values
    let LOW_BORDER : Float = 6500.0
    let MEDIUM_BORDER : Float = 13000.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureProgressViews()
        updateProgressBars()
        configureLabelGestures()
        updateDisplay()
    }
    
    func updateDisplay(){
        if let goal = Activities.shared.currentGoal {
            goalDistanceLabel.text = String(Int(goal.distance!))
            goalCaloriesLabel.text = "About " + String(goal.calories!) + " kcal"
            goalWalkingLabel.text = String(goal.walkingTime!) + "min"
            goalRunningLabel.text = String(goal.runningTime!) + "min"
            goalBicycling.text = String(goal.bicyclingTime!) + "min"
            goalSlider.value = goal.distance!
        }
    }
    
    
    func updateProgressBars(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.MM"
        let date = Date()
        let today = dateFormatter.string(from: date)
        var totalTodayWalkingDistance : Float = 0.0
        var totalTodayRunningDistance : Float = 0.0
        var totalTodayBicyclingDistance : Float = 0.0
        
        for todayRun in Activities.shared.listOfRuns{
            if (dateFormatter.string(from: todayRun.date!).elementsEqual(today)){
                if let goal = Activities.shared.currentGoal{
                    switch todayRun.style! {
                    case "walking":
                        totalTodayWalkingDistance += todayRun.distance!
                        let maxDistance = goal.distance!
                        let runDistance = totalTodayWalkingDistance * 100 / maxDistance
                        if (runDistance > maxDistance){
                            walkingProgressView.setProgress(1, animated: true)
                        } else {
                            walkingProgressView.setProgress(Float(runDistance/100), animated: true)
                        }
                    case "running":
                        totalTodayRunningDistance += todayRun.distance!
                        let maxDistance = goal.distance!
                        let runDistance = totalTodayRunningDistance * 100 / maxDistance
                        if (runDistance > maxDistance){
                            runningProgressView.setProgress(1, animated: true)
                        } else {
                            runningProgressView.setProgress(Float(runDistance/100), animated: true)
                        }
                    case "bicycling":
                        totalTodayBicyclingDistance += todayRun.distance!
                        let maxDistance = goal.distance!
                        let runDistance = totalTodayBicyclingDistance * 100 / maxDistance
                        if (runDistance > maxDistance){
                            bicyclingProgressView.setProgress(1, animated: true)
                        } else {
                            bicyclingProgressView.setProgress(Float(runDistance/100), animated: true)
                        }
                    default:
                        break
                    }
                }
                
            }
        }
        walkingLabel.text = String(format: "%.1f", totalTodayWalkingDistance/1000) + "km"
        runningLabel.text = String(format: "%.1f", totalTodayRunningDistance/1000) + "km"
        bicyclingLabel.text = String(format: "%.1f", totalTodayBicyclingDistance/1000) + "km"
        
    }
    
    func configureLabelGestures(){
        
      
        let walkingGesture : UIGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(onWalkingLabelClick))
        walkingLabel.isUserInteractionEnabled = true
        walkingLabel.addGestureRecognizer(walkingGesture)
        
        let runningGesture : UIGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(onRunningLabelClick))
        runningLabel.isUserInteractionEnabled = true
        runningLabel.addGestureRecognizer(runningGesture)
        
        let bicyclingGesture : UIGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(onBicyclingLabelClick))
        bicyclingLabel.isUserInteractionEnabled = true
        bicyclingLabel.addGestureRecognizer(bicyclingGesture)
    }
    
    @objc func onWalkingLabelClick(){
        let destVC = storyboard?.instantiateViewController(withIdentifier: "ActivityVC") as! ActivityVC
        destVC.style = "walking"
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    @objc func onRunningLabelClick(){
        let destVC = storyboard?.instantiateViewController(withIdentifier: "ActivityVC") as! ActivityVC
        destVC.style = "running"
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    @objc func onBicyclingLabelClick(){
        let destVC = storyboard?.instantiateViewController(withIdentifier: "ActivityVC") as! ActivityVC
        destVC.style = "bicycling"
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    
    
    func configureProgressViews(){
        walkingProgressView.clipsToBounds = true
        walkingProgressView.layer.cornerRadius = 7
        walkingProgressView.subviews[1].clipsToBounds = true
        walkingProgressView.subviews[1].layer.cornerRadius = 7
        
        runningProgressView.clipsToBounds = true
        runningProgressView.layer.cornerRadius = 7
        runningProgressView.subviews[1].clipsToBounds = true
        runningProgressView.subviews[1].layer.cornerRadius = 7
        
        bicyclingProgressView.clipsToBounds = true
        bicyclingProgressView.layer.cornerRadius = 7
        bicyclingProgressView.subviews[1].clipsToBounds = true
        bicyclingProgressView.subviews[1].layer.cornerRadius = 7
        
    }
    
    @IBAction func onSaveChangesButtonClick(_ sender: Any) {
        Activities.shared.currentGoal = Goal.init(goalSlider.value, Int(goalSlider.value)/10, difficulty!, Int(goalSlider.value)/50, Int(goalSlider.value)/70, Int(goalSlider.value)/100)
        if (delegate != nil){
            delegate!.activitiesVCDidSaveGoal()
            navigationController?.popViewController(animated: true)
        }
        updateProgressBars()
        
    }
    
    @IBAction func onGoalSlideValueChanged(_ sender: Any) {
        if (goalSlider.value < LOW_BORDER){
            goalLowLabel.textColor = UIColor.init(named: "lightBlue")
            goalMediumLabel.textColor = .black
            goalHighLabel.textColor = .black
            difficulty = "low"
        } else if (goalSlider.value > LOW_BORDER && goalSlider.value < MEDIUM_BORDER){
            goalMediumLabel.textColor = UIColor.init(named: "lightBlue")
            goalLowLabel.textColor = .black
            goalHighLabel.textColor = .black
            difficulty = "medium"
        } else {
            goalHighLabel.textColor = UIColor.init(named: "lightBlue")
            goalMediumLabel.textColor = .black
            goalLowLabel.textColor = .black
            difficulty = "high"
        }
        goalDistanceLabel.text = String(Int(goalSlider.value))
        goalCaloriesLabel.text = "About " + String(Int(goalSlider.value)/10) + " kcal"
        
        goalWalkingLabel.text = String(Int(goalSlider.value)/50) + "min"
        goalRunningLabel.text = String(Int(goalSlider.value)/70) + "min"
        goalBicycling.text = String(Int(goalSlider.value)/100) + "min"
    }
    
    
    
    
}
