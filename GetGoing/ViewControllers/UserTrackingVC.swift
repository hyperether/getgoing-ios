//
//  UserTrackingVC.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/5/19.
//  Copyright © 2019 Milan Vidovic. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation



class UserTrackingVC: UIViewController{

    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var roundViewBehind: UIView!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var distanceStackView: UIStackView!
    
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var setYourGoalButton: UIButton!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    
    var lm = LocationManager.shared

    var startButtonIsClicked = false
    
    var chosenStyle : String!
    var chosenWeight = DatabaseManager.instance.selectUser()?.weight
    
    //Time count
    var timer = Timer()
    var counter = 0.0
    
    //Route info
    var distanceCovered = 0.0
    var calories = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lm.delegate = self
        lm.upperSpeedBound = setSpeedLimit()
        
        updateDisplay()
        configureNavigationBar()
        makeRoundViews()
        mapSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLocationManagerStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        lm.clManager.stopUpdatingLocation()
    }
    
    
    @IBAction func onSetYourGoalButtonClick(_ sender: Any) {
        if let destVC = storyboard?.instantiateViewController(withIdentifier: "ActivitiesVC") as? ActivitiesVC {
            destVC.delegate = self
            navigationController?.pushViewController(destVC, animated: true)
        }
        
    }
    
    func updateDisplay(){
        
        if let _ = Activities.shared.currentGoal {
            infoStackView.isHidden = false
            distanceStackView.isHidden = false
            setYourGoalButton.isHidden = true
        } else {
            infoStackView.isHidden = true
            distanceStackView.isHidden = true
            setYourGoalButton.isHidden = false
        }
    }
    
    func setSpeedLimit() -> Double{
        switch chosenStyle {
        case "walking":
            return 3
        case "running":
            return 5
        case "bicycling":
            return 15
        default:
            return 15
        }
    }
    
    
    func makeRoundViews(){
        roundView.layer.cornerRadius = roundView.frame.size.width/2
        roundView.clipsToBounds = true
        
        roundViewBehind.layer.cornerRadius = roundViewBehind.frame.size.width/2
        roundViewBehind.clipsToBounds = true
    }
    
    
    func mapSetup(){
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = .standard
        mapView.userTrackingMode = .follow
    }
    
    func checkLocationManagerStatus(){
        if let status = lm.clStatus {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                lm.clManager.startUpdatingLocation()
            case .denied:
                self.showDestructivePrompt(title: "Location access denied", message: "You can change access in settings.", buttonTitle: "Ok", handler: {_ in
                    self.navigationController?.popViewController()
                })
                
            default:
                break
            }
        }
        
    }
    
    public func calculateCalories(dis: Double, vel: Double, weight: Double) -> Double {
        let kcalMatrix = [[0.89, 0.00078],
                          [1.12, 0.00074],
                          [1.34, 0.00073],
                          [1.56, 0.00071],
                          [1.79, 0.00078],
                          [2.01, 0.00087],
                          [2.23, 0.00099],
                          [2.68, 0.00104],
                          [3.13, 0.00102],
                          [3.58, 0.00105],
                          [4.02, 0.00104],
                          [4.47, 0.00112]]
        
        var energySpent: Double = 0
         
        switch chosenStyle {
        case "walking","running":
            if vel < kcalMatrix[0][0] {// if the measured speed is lower than the
                // first entry use the first entry
                energySpent = dis * (kcalMatrix[0][1] * weight)
            } else if vel > kcalMatrix[11][0] {// if the measured speed is higher
                // than the last entry use the
                // last entry
                energySpent = dis * (kcalMatrix[11][1] * weight);
            } else {
                for i in 1...12 {
                    if (vel < kcalMatrix[i][0]) { // take the next higher value
                        energySpent = dis * (kcalMatrix[i][1] * weight)
                        break
                    }
                }
            }
        case "bicycling":
            if (vel < 4.47) {
                energySpent = dis * (0.000779 * weight);    // riding velocity lower than 16 km/h
            } else {
                energySpent = dis * (0.001071 * weight);    // riding velocity higher than 16 km/h
            }
        default: break
        }
        
        return energySpent
    }
  
    
    @IBAction func onStartButtonClick(_ sender: Any) {
        if (!startButtonIsClicked) {
            if (Activities.shared.currentGoal == nil){
                self.showInfoMessage(message: "You need to set goal in order to start run")
            } else {
                startButtonIsClicked = true
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
                playPauseButton.setImage(UIImage.init(named: "pause"), for: .normal)
                LocationManager.shared.resetLocationManager()
            }
            
        } else {
            startButtonIsClicked = false
            timer.invalidate()
            playPauseButton.setImage(UIImage.init(named: "play"), for: .normal)
            LocationManager.shared.addRoute()
        }
    }
    
    @objc func updateTimer() {
        counter = counter + 0.1
        var time = (h: 0, m: 0, s: 0)
        time = secondsToHoursMinutesSeconds(seconds: Int(counter))
        timeLabel.text = String("\(time.h):\(time.m):\(time.s)")
    }
    
    @IBAction func onLocateButtonClick(_ sender: Any) {
        mapView.userTrackingMode = .follow
    }
    
    
    @IBAction func onClearButtonClick(_ sender: Any) {
        self.showDestructivePrompt(title: "Clear route data?", message: "Clear map and route data", buttonTitle: "Ok") { _ in
            self.resetRunInfo()
        }
    }
    
    func resetRunInfo(){
        self.mapView.removeOverlays(self.mapView.overlays)
        self.timer.invalidate()
        self.counter = 0.0
        self.distanceCovered = 0.0
        self.distanceLabel.text = "0"
        self.timeLabel.text = "0:0:0"
        self.speedLabel.text = "0.0"
        self.caloriesLabel.text = "0"
        self.startButtonIsClicked = false
        self.playPauseButton.setImage(UIImage.init(named: "play"), for: .normal)
    }
    

    
    @IBAction func onSaveButtonClick(_ sender: Any) {
        guard let goal = Activities.shared.currentGoal else {
            return
        }
        if (startButtonIsClicked){
            self.showInfoMessage(message: "You need to pause your run in order to save it")
        }else {
            if (distanceCovered > 0.0){
                self.showDestructivePrompt(title: "Save run?", message: "Saves map and route data", buttonTitle: "Ok") { _ in
                let runToSave = Run(Date.init(), Float(self.distanceCovered), self.chosenStyle, Int(self.counter), self.calories, Float(self.distanceCovered/self.counter), goal, Activities.shared.listOfRoutes)
                DatabaseManager.instance.saveRunToDb(run: runToSave)
                Activities.shared.addRunToLists(run: runToSave)
                self.resetRunInfo()
                LocationManager.shared.resetLocationManager()
                }
            } else {
                self.showInfoMessage(message: "No run recorded.")
            }
        }
        
    
    }
    

}

extension UserTrackingVC : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.init(named: "lightBlue")
        renderer.lineWidth = 4.0
        
        return renderer
    }

    
    
}

extension UserTrackingVC : ActivitiesVCDelegate {
    
    func activitiesVCDidSaveGoal() {
        updateDisplay()
    }
    
}

extension UserTrackingVC : LocationManagerDelegate {
    func locationManagerFoundNewLocation(_ difference: Double, _ polyline: MKPolyline,_ speed: Double) {
        if (startButtonIsClicked){
            mapView.addOverlay(polyline)
            distanceCovered += difference
            //calories += Int(difference/10)
            distanceLabel.text = String(format: "%.2f", distanceCovered)
            speedLabel.text = String(format: "%.2f", (speed))
            calories = Int(calculateCalories(dis: distanceCovered, vel: speed, weight: Double(chosenWeight!)))
            caloriesLabel.text = String(format: "%.2f", calculateCalories(dis: distanceCovered, vel: speed, weight: Double(chosenWeight!)))
            
        }
        
    }
    
    
}
