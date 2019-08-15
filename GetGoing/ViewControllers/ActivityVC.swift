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
    
        
    
    //labels to update
    @IBOutlet weak var bigDistanceLabel: UILabel!
    @IBOutlet weak var smallDistanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    
    @IBOutlet weak var chartCollectionView: UICollectionView!
    
    
    //constrains
    @IBOutlet weak var mapHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var expandableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var roundProgressBottomConstraint: NSLayoutConstraint!
    
    var lastRunWithStyle : Run?
    
    let chartCellIdentifier = "ChartCell"
    let chartCellNib = UINib.init(nibName: "ChartCell", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chartCollectionView.delegate = self
        chartCollectionView.dataSource = self
        chartCollectionView.register(chartCellNib, forCellWithReuseIdentifier: chartCellIdentifier)
        configureNavigationBar()
        expandableView.layer.cornerRadius = 30
        mapView.layer.cornerRadius = 30
        mapView.delegate = self
        lastRunWithStyle = Activities.shared.returnRunsWithStyle(style: style!).last
        updateDisplay()
        
        
        
        
    }
    
    
    func updateDisplay(){
        
        if let lastRun = lastRunWithStyle{
            let maxDistance = lastRun.goal!.distance!
            let runDistance = lastRun.distance! * 100 / maxDistance
            if (runDistance > maxDistance){
                roundProgress.setProgress(progress: 1)
            } else {
                roundProgress.setProgress(progress: CGFloat(runDistance/100))
            }
            bigDistanceLabel.text = String(Int(lastRun.distance!))
            smallDistanceLabel.text = String(Int(lastRun.distance!/1000))
            averageSpeedLabel.text = String(format: "%.1f",lastRun.averageSpeed!)
            caloriesLabel.text = String(lastRun.calories!)
            configureMap(lastRun.route!)
        } else {
            resetDisplay()
        }
        
    }
    
    func resetDisplay(){
        roundProgress.setProgress(progress: 0)
        bigDistanceLabel.text = String(0.0)
        smallDistanceLabel.text = String(0.0)
        averageSpeedLabel.text = String(0.0)
        caloriesLabel.text = String(0)
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
    }
    
   
    
    func configureMap(_ route : [MKOverlay]){
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        
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
    
    @IBAction func onTrashButtonClick(_ sender: Any) {
        guard let runToDelete = lastRunWithStyle else {
            return
        }
        DatabaseManager.instance.deleteRun(run: runToDelete)
        Activities.shared.removeRun(runToDelete: runToDelete)
        showInfoMessage(message: "Run removed")
        lastRunWithStyle = Activities.shared.returnRunsWithStyle(style: style!).last
        chartCollectionView.reloadData()
        updateDisplay()
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

extension ActivityVC : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Activities.shared.returnRunsWithStyle(style: style!).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard  let cell = chartCollectionView.dequeueReusableCell(withReuseIdentifier: chartCellIdentifier, for: indexPath) as? ChartCell else {
            return UICollectionViewCell()
        }
        let runList = Activities.shared.returnRunsWithStyle(style: style!)
        
        cell.dateLabel.text = getShortStringFromDate(date: runList[indexPath.item].date!)
        
        let maxDistance = runList[indexPath.item].goal!.distance!
        let runDistance = runList[indexPath.item].distance! * 100 / maxDistance
        if (runDistance <= maxDistance){
            cell.barHeightConstraint.constant = CGFloat(runDistance)
        }
        
        cell.barView.layer.cornerRadius = 5
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let runList = Activities.shared.returnRunsWithStyle(style: style!)
        
        lastRunWithStyle = runList[indexPath.item]
        updateDisplay()
        
    }
    
    
    
    
    
}


