//
//  ActivityVC.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/7/19.
//  Copyright © 2019 Milan Vidovic. All rights reserved.
//

import UIKit
import MapKit


class ActivityVC : UIViewController {
    
    var expandButtonClicked = false
    var style : String?
    var progress : Float?
    
    @IBOutlet weak var expandableView: UIView!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var infoStackVIew: UIStackView!
    @IBOutlet weak var roundProgress: MKMagneticProgress!
    @IBOutlet weak var trophyImage: UIImageView!
    @IBOutlet weak var distanceStackView: UIStackView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    //chart
    @IBOutlet weak var basicBarChart: BasicBarChart!
    
    
    
    //labels to update
    @IBOutlet weak var bigDistanceLabel: UILabel!
    @IBOutlet weak var smallDistanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    
    
    //constrains
    @IBOutlet weak var mapHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var expandableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var roundProgressBottomConstraint: NSLayoutConstraint!
    
    var lastRunWithStyle : Run?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        expandableView.layer.cornerRadius = 30
        mapView.layer.cornerRadius = 30
        mapView.delegate = self
        
        for run in Activities.shared.listOfRuns{
            if (run.style!.lowercased().elementsEqual(style!)){
                lastRunWithStyle = run
            }
        }
        if (lastRunWithStyle != nil){
            updateDisplay()
        }
        
        let dataEntries = generateRandomDataEntries()
        basicBarChart.updateDataEntries(dataEntries: dataEntries, animated: true)
    
        
        
    }
    
    
    func generateRandomDataEntries() -> [DataEntry] {
        var result: [DataEntry] = []
        for i in 0..<10 {
            let value = (arc4random() % 90) + 10
            let height: Float = Float(value) / 100.0
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d.MM"
            var date = Date()
            date.addTimeInterval(TimeInterval(24*60*60*i))
            result.append(DataEntry(color: UIColor.init(named: "lightBlue")!, height: height, textValue: "", title: formatter.string(from: date)))
        }
        return result
    }
    

    
    func updateDisplay(){
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "d.MM"
        let date = Date()
        let today = dateFormatter.string(from: date)
        var listOfRoutes : [[MKOverlay]] = []
        var totalAverageSpeed : [Float] = []
        var totalCalories : Int = 0
        var totalDistance : Float = 0.0
        for todayRun in Activities.shared.listOfRuns{
            if (dateFormatter.string(from: todayRun.date!).elementsEqual(today) && todayRun.style!.elementsEqual(self.style!)){
                totalDistance += todayRun.distance!
                totalAverageSpeed.append(todayRun.averageSpeed!)
                totalCalories += todayRun.calories!
                listOfRoutes.append(todayRun.route!)
                let maxDistance = todayRun.goal!.distance!
                let runDistance = totalDistance * 100 / maxDistance
                if (runDistance > maxDistance){
                    roundProgress.setProgress(progress: 1)
                } else {
                    roundProgress.setProgress(progress: CGFloat(runDistance/100))
                }
                bigDistanceLabel.text = String(Int(totalDistance))
                smallDistanceLabel.text = String(Int(totalDistance/1000))
                averageSpeedLabel.text = String(format: "%.1f",totalAverageSpeed.reduce(0, +)/Float(totalAverageSpeed.count))
                caloriesLabel.text = String(totalCalories)
            }
        }
        
        for route in listOfRoutes {
            configureMap(route)
        }
    }
    
    func configureMap(_ route : [MKOverlay]){
        let point = route.first!
        mapView.centerCoordinate = point.coordinate
        let center = CLLocationCoordinate2D(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
        mapView.addOverlays(route)
        
        let startRegion = CLCircularRegion(center: route.first!.coordinate, radius: 8, identifier: "start")
        
        var circle = MKCircle(center: route.first!.coordinate, radius: startRegion.radius)
        mapView.addOverlay(circle)
        let endRegion = CLCircularRegion(center: route.last!.coordinate, radius: 8, identifier: "end")
        circle = MKCircle(center: route.last!.coordinate, radius: endRegion.radius)
        mapView.addOverlay(circle)
    }
    
    @IBAction func onExpandButtonClick(_ sender: Any) {
        if (!expandButtonClicked){
            expandButton.setImage(UIImage.init(named: "chevron-down"), for: .normal)
            UIView.animate(withDuration: 1) {
                self.roundProgress.alpha = 0
                self.trophyImage.alpha = 0
                self.distanceStackView.alpha = 0
                self.roundProgressBottomConstraint.constant = 0.0
                self.expandableViewHeightConstraint.constant = self.view.frame.height*2/3 + 50
                self.mapHeightConstraint.constant = self.mapView.frame.width
                self.view.layoutIfNeeded()
            }
            expandButtonClicked = true

        } else {
            
            expandButton.setImage(UIImage.init(named: "chevron-up"), for: .normal)
            UIView.animate(withDuration: 1) {
                self.expandableViewHeightConstraint.constant = 220
                self.mapHeightConstraint.constant = 0
                self.roundProgress.alpha = 1
                self.trophyImage.alpha = 1
                self.distanceStackView.alpha = 1
                self.roundProgressBottomConstraint.constant = 10.0
                self.view.layoutIfNeeded()
            }
   
           
            expandButtonClicked = false
        }
        
    }
    
    
}

extension ActivityVC : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circelOverLay = overlay as? MKCircle else {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.init(named: "lightBlue")
            renderer.lineWidth = 4.0
            
            return renderer
            
        }
        
        let circleRenderer = MKCircleRenderer(circle: circelOverLay)
        circleRenderer.strokeColor = UIColor.init(named: "lightBlue")
        circleRenderer.fillColor = .blue
        circleRenderer.alpha = 0.5
        return circleRenderer
       
    }
    
    
}


