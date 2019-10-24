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
    
    var runStyle: String?
    let step: Float = 100
    //border values
    let LOW_BORDER : Float = 6500.0
    let MEDIUM_BORDER : Float = 13000.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureProgressViews()
        
        configureLabelGestures()
        updateDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateProgressBars()
    }
    
    func updateDisplay(){
        if let goal = Activities.shared.currentGoal {
            goalDistanceLabel.text = String(Int(goal.distance!))
            goalCaloriesLabel.text = "About " + String(goal.calories!) + " kcal"
            goalWalkingLabel.text = String(goal.walkingTime!) + "min"
            goalRunningLabel.text = String(goal.runningTime!) + "min"
            goalBicycling.text = String(goal.bicyclingTime!) + "min"
            goalSlider.value = goal.distance!
            changeDifficultyTextColor()
        }
    }
    
    
    func updateProgressBars(){

        let today = getShortStringFromDate(date: Date())
        var totalTodayWalkingDistance : Float = 0.0
        var totalTodayRunningDistance : Float = 0.0
        var totalTodayBicyclingDistance : Float = 0.0
        
        walkingProgressView.setProgress(0, animated: false)
        runningProgressView.setProgress(0, animated: false)
        bicyclingProgressView.setProgress(0, animated: false)
        
        for todayRun in Activities.shared.listOfRuns{
            let runDate = getShortStringFromDate(date: todayRun.date!)
            if (runDate.elementsEqual(today)){
                if let goal = Activities.shared.currentGoal{
                    switch todayRun.style! {
                    case "walking":
                        totalTodayWalkingDistance += todayRun.distance!
                        if (totalTodayWalkingDistance >= goal.distance!){
                            walkingProgressView.setProgress(1, animated: false)
                        } else {
                            let maxDistance = goal.distance!
                            let runDistance = totalTodayWalkingDistance * 100 / maxDistance
                            walkingProgressView.setProgress(Float(runDistance/100), animated: false)
                        }
                    case "running":
                        totalTodayRunningDistance += todayRun.distance!
                        if (totalTodayRunningDistance >= goal.distance!){
                            runningProgressView.setProgress(1, animated: false)
                        } else {
                            let maxDistance = goal.distance!
                            let runDistance = totalTodayRunningDistance * 100 / maxDistance
                            runningProgressView.setProgress(Float(runDistance/100), animated: false)
                        }
                    case "bicycling":
                        totalTodayBicyclingDistance += todayRun.distance!
                        if (totalTodayBicyclingDistance >= goal.distance!){
                            bicyclingProgressView.setProgress(1, animated: false)
                        } else {
                            let maxDistance = goal.distance!
                            let runDistance = totalTodayBicyclingDistance * 100 / maxDistance
                            bicyclingProgressView.setProgress(Float(runDistance/100), animated: false)
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
        if let destVC = storyboard?.instantiateViewController(withIdentifier: "ActivityVC") as? ActivityVC {
            destVC.style = "walking"
            navigationController?.pushViewController(destVC, animated: true)
        }
        
    }
    
    @objc func onRunningLabelClick(){
        if let destVC = storyboard?.instantiateViewController(withIdentifier: "ActivityVC") as? ActivityVC {
            destVC.style = "running"
            navigationController?.pushViewController(destVC, animated: true)
        }
        
    }
    
    @objc func onBicyclingLabelClick(){
        if let destVC = storyboard?.instantiateViewController(withIdentifier: "ActivityVC") as? ActivityVC {
            destVC.style = "bicycling"
            navigationController?.pushViewController(destVC, animated: true)
        }
        
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
        Activities.shared.currentGoal = Goal.init(goalSlider.value, Int(Double(goalSlider.value) * 0.00112 * Double((DatabaseManager.instance.selectUser()?.weight!)!)), difficulty!, Int( goalSlider.value / (1.5 * 60) ), Int( goalSlider.value / (2.5 * 60) ), Int( goalSlider.value / (5 * 60) ))
        if (delegate != nil){
            delegate!.activitiesVCDidSaveGoal()
            navigationController?.popViewController(animated: true)
        } else {
            self.showInfoMessage(message: "Goal saved!")
        }
        updateProgressBars()
        
        
    }
    
    
    @IBAction func onGoalSlideValueChanged(_ sender: Any) {
        changeDifficultyTextColor()
        let roundedValue = round(goalSlider.value / step) * step
        goalSlider.value = roundedValue
        goalDistanceLabel.text = String(Int(goalSlider.value))
        goalCaloriesLabel.text = "About " + String(Int(Double(goalSlider.value) * 0.00112 * Double((DatabaseManager.instance.selectUser()?.weight!)!))) + " kcal"
        
        goalWalkingLabel.text = String(Int( goalSlider.value / (1.5 * 60) )) + "min"
        goalRunningLabel.text = String(Int( goalSlider.value / (2.5 * 60) )) + "min"
        goalBicycling.text = String(Int( goalSlider.value / (5 * 60) )) + "min"
    }
    
    func changeDifficultyTextColor(){
        if (goalSlider.value < LOW_BORDER){
            goalLowLabel.textColor = UIViewController.lightBlueColor
            goalMediumLabel.textColor = .black
            goalHighLabel.textColor = .black
            difficulty = "low"
        } else if (goalSlider.value > LOW_BORDER && goalSlider.value < MEDIUM_BORDER){
            goalMediumLabel.textColor = UIViewController.lightBlueColor
            goalLowLabel.textColor = .black
            goalHighLabel.textColor = .black
            difficulty = "medium"
        } else {
            goalHighLabel.textColor = UIViewController.lightBlueColor
            goalMediumLabel.textColor = .black
            goalLowLabel.textColor = .black
            difficulty = "high"
        }
    }
    
    
    
    
}
