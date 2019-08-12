//
//  ViewController.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/5/19.
//  Copyright © 2019 Milan Vidovic. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation



class ViewController: UIViewController{

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
    

    var locationManager = CLLocationManager()
    var startButtonIsClicked = false
    
    var chosenStyle : String!
    
    //Time count
    var timer = Timer()
    var counter = 0.0
    
    //Route info
    var listOfLocations : [CLLocation] = []
    var distanceCovered = 0.0
    var routeOverlay : [MKOverlay]?
    var calories = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDisplay()
        configureLocationManager()
        configureNavigationBar()
        makeRoundViews()
        mapSetup()
    }
    
    
    @IBAction func onSetYourGoalButtonClick(_ sender: Any) {
        let destVC = storyboard?.instantiateViewController(withIdentifier: "ActivitiesVC") as! ActivitiesVC
        destVC.delegate = self
        navigationController?.pushViewController(destVC, animated: true)
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
    
    
    func makeRoundViews(){
        roundView.layer.cornerRadius = roundView.frame.size.width/2
        roundView.clipsToBounds = true
        
        roundViewBehind.layer.cornerRadius = roundViewBehind.frame.size.width/2
        roundViewBehind.clipsToBounds = true
    }
    
    func configureLocationManager(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    func mapSetup(){
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = .standard
        mapView.userTrackingMode = .follow
    }
  
    
    @IBAction func onStartButtonClick(_ sender: Any) {
        if (!startButtonIsClicked) {
            startButtonIsClicked = true
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            playPauseButton.setImage(UIImage.init(named: "pause"), for: .normal)
        } else {
            startButtonIsClicked = false
            timer.invalidate()
            playPauseButton.setImage(UIImage.init(named: "play"), for: .normal)

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
        let alert = UIAlertController(title: "Clear route data", message: "Clear map and route data", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: {_ in
            self.routeOverlay = self.mapView.overlays
            self.mapView.removeOverlays(self.mapView.overlays)
            self.timer.invalidate()
            self.counter = 0.0
            self.distanceCovered = 0.0
            self.routeOverlay = nil
            self.distanceLabel.text = "0"
            self.timeLabel.text = "0:0:0"
            self.speedLabel.text = "0.00"
            self.caloriesLabel.text = "0"
            self.startButtonIsClicked = false
        })
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    

    
    @IBAction func onSaveButtonClick(_ sender: Any) {
        //add alert, cover critical cases
        guard let goal = Activities.shared.currentGoal else {
            return
        }
        self.routeOverlay = self.mapView.overlays
        let runToSave = Run(Date.init(), Float(distanceCovered), routeOverlay!, chosenStyle, Int(counter), calories, Float(distanceCovered/counter), goal)
        Activities.shared.listOfRuns.append(runToSave)
    
    }
    

}

extension ViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.init(named: "lightBlue")
        renderer.lineWidth = 4.0
        
        return renderer
    }

    
    
}

extension ViewController : CLLocationManagerDelegate {
    

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
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
            if let lastLocation = listOfLocations.last{
                if (startButtonIsClicked) {
                    let difference = newLocation.distance(from: lastLocation)
                    let area = [lastLocation.coordinate,newLocation.coordinate]
                    let polyline = MKPolyline(coordinates: area, count: area.count)
                    mapView.addOverlay(polyline)
                    distanceCovered += difference
                    calories += Int(difference/10)
                    routeOverlay?.append(polyline)
                    distanceLabel.text = String(format: "%.2f", distanceCovered)
                    speedLabel.text = String(format: "%.2f", (distanceCovered / counter))
                    caloriesLabel.text = String(calories)
                }
                
            }
            listOfLocations.append(newLocation)
        }
    }
}

extension ViewController : ActivitiesVCDelegate {
    
    func activitiesVCDidSaveGoal() {
        updateDisplay()
    }
    
}


