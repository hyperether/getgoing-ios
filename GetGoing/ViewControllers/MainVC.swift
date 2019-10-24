//
//  MainVC.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/5/19.
//  Copyright © 2019 Milan Vidovic. All rights reserved.
//

import UIKit
import FSPagerView

class MainVC : UIViewController {
    
    var chosenStyle : String = "Walking"
    @IBOutlet weak var movingStyleLabel: UILabel!
    let db = DatabaseManager.instance
    var user : UserProfile = UserProfile.init(20, "Male", Date.init(), 150, 50)
    
    //round views
    @IBOutlet weak var rearRoundView: UIView!
    @IBOutlet weak var frontRoundView: UIView!
    
    //last run info
    @IBOutlet weak var lastStyleImageView: UIImageView!
    @IBOutlet weak var lastDistanceLabel: UILabel!
    @IBOutlet weak var lastStyleLabel: UILabel!
    
    @IBOutlet weak var lastCaloriesLabel: UILabel!
    
    
    @IBOutlet weak var lastTimeNumberLabel: UILabel!
    @IBOutlet weak var lastTimeTextLabel: UILabel!
    
    @IBOutlet weak var shapedView: UIView!
    @IBOutlet weak var circularProgress: MKMagneticProgress!
    
    @IBOutlet weak var pagerView: FSPagerView!
    
    static let pagerCellIdentifier = "pagerMainCell"
    static let pagerCellNib = UINib(nibName: "pagerMainCell", bundle: nil)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db.insertOrUpdateUser(user: user)
        pagerViewConfigure()
        if let runs = db.selectRuns(){
            Activities.shared.listOfRuns = runs
            Activities.shared.configureRunStylesTables()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplay()
        updateGoal()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        makeRoundViews()
    }
    
    func pagerViewConfigure(){
        
        pagerView.register(MainVC.pagerCellNib, forCellWithReuseIdentifier: MainVC.pagerCellIdentifier)
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.transformer = FSPagerViewTransformer(type: .linear)
        pagerView.isInfinite = true
        pagerView.decelerationDistance = 1
        if let cell = pagerView.cellForItem(at: 0) as? PagerMainCell{
            cell.styleImageVIew.image = UIImage.init(named: "walking (2)")
        }
    }
    
    func makeRoundViews(){
        frontRoundView.layer.cornerRadius = frontRoundView.frame.size.width/2
        frontRoundView.clipsToBounds = true
        
        rearRoundView.layer.cornerRadius = rearRoundView.frame.size.width/2
        rearRoundView.clipsToBounds = true
    }
    
    func updateDisplay(){
        //value changes
        movingStyleLabel.text = chosenStyle
        if let lastRun = Activities.shared.listOfRuns.last {
            if let goal = lastRun.goal{
                if (lastRun.distance! >= goal.distance!) {
                   circularProgress.setProgress(progress: 1)
                } else {
                    let maxDistance = goal.distance!
                    let runDistance = lastRun.distance! * 100 / maxDistance
                    circularProgress.setProgress(progress: CGFloat(runDistance/100))
                }
                changeLastRunImage(lastRun.style!)
                lastDistanceLabel.text = String(format: "%.1f", lastRun.distance! / 1000) + "km"
                var lastRunStyle = lastRun.style!
                lastRunStyle = lastRunStyle.prefix(1).capitalized + lastRunStyle.dropFirst()
                lastStyleLabel.text = lastRunStyle
                lastCaloriesLabel.text = String(lastRun.calories!)
                let time = secondsToHoursMinutesSeconds(seconds: lastRun.timeInSeconds!)
                if (time.0 != 0){
                    lastTimeNumberLabel.text = String(time.0)
                    lastTimeTextLabel.text = "h"
                } else if (time.1 != 0){
                    lastTimeNumberLabel.text = String(time.1)
                    lastTimeTextLabel.text = "min"
                } else {
                    lastTimeNumberLabel.text = String(time.2)
                    lastTimeTextLabel.text = "sec"
                }
                
            }
        } else {
            resetDisplay()
        }
    
    }
    
    func updateGoal(){
        if (Activities.shared.currentGoal == nil){
            if let lastRun = Activities.shared.listOfRuns.last{
                let todayDate = getShortStringFromDate(date: Date())
                if (todayDate.elementsEqual(getShortStringFromDate(date: lastRun.date!))){
                    Activities.shared.currentGoal = lastRun.goal
                }
            }
        }
        
    }
    
    func resetDisplay(){
        circularProgress.setProgress(progress: 0.5)
        circularProgress.setProgress(progress: 0.0)
        changeLastRunImage("walking")
        lastDistanceLabel.text = "0.0km"
        lastStyleLabel.text = "Walking"
        lastCaloriesLabel.text = "0"
        lastTimeNumberLabel.text = "0"
        lastTimeTextLabel.text = "sec"
    }
    
    
    func changeLastRunImage(_ style : String) {
        switch style {
        case "walking":
            lastStyleImageView.image = UIImage.init(named: "walking (3)")
        case "running":
            lastStyleImageView.image = UIImage.init(named: "running (3)")
        case "bicycling":
            lastStyleImageView.image = UIImage.init(named: "solid (3)")
        default:
            break
        }
    }
    
 
    @IBAction func onViewAllButtonClick(_ sender: Any) {
        if let destVC = storyboard?.instantiateViewController(withIdentifier: "ActivitiesVC") as? ActivitiesVC{
            navigationController?.pushViewController(destVC, animated: true)
        }
        
    }
    
    
    
    @IBAction func onGetReadyButtonClick(_ sender: Any) {
        if let destVC = storyboard?.instantiateViewController(withIdentifier: "UserTrackingVC") as? UserTrackingVC {
            destVC.chosenStyle = self.chosenStyle.lowercased()
            navigationController?.pushViewController(destVC, animated: true)
        }
        
        
    }
    
    @IBAction func onProfileButtonClick(_ sender: Any) {
        if let destVC = storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC{
            self.navigationController?.pushViewController(destVC, animated: true)
        }
        
    }
    
    
    func changeStyle(_ style : String) {
        chosenStyle = style
        movingStyleLabel.text = chosenStyle
    }
    
    
}

extension MainVC : FSPagerViewDelegate, FSPagerViewDataSource{
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 3
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: MainVC.pagerCellIdentifier, at: index) as? PagerMainCell else {
            return PagerMainCell()
        }
       
        cell.contentMode = .center
        if (index == 0){
            cell.styleName = "Walking"
            if (pagerView.cellForItem(at: 1) == nil){
                cell.styleImageVIew.image = UIImage.init(named: "walking (2)")
            } else {
                cell.styleImageVIew.image = UIImage.init(named: "walking (1)")
            }
        } else if (index == 1){
            cell.styleName = "Running"
            cell.styleImageVIew.image = UIImage.init(named: "running (2)")
        } else {
            cell.styleName = "Bicycling"
            cell.styleImageVIew.image = UIImage.init(named: "solid (2)")
        }
        return cell
    }
    

    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        switch targetIndex {
        case 0:
            changeStyle("Walking")
        case 1:
            changeStyle("Running")
        case 2:
            changeStyle("Bicycling")
        default:
            break
        }
        updateCellImages(mainCellIndex: targetIndex)
        
    }
    
    func updateCellImages(mainCellIndex : Int){
        guard let walkingCell = pagerView.cellForItem(at: 0) as? PagerMainCell,
              let runningCell = pagerView.cellForItem(at: 1) as? PagerMainCell,
              let bicyclingCell = pagerView.cellForItem(at: 2) as? PagerMainCell
        else {
            return
        }
        
        
       
        switch mainCellIndex {
        case 0:
            walkingCell.styleImageVIew.image = UIImage.init(named: "walking (2)")
            runningCell.styleImageVIew.image = UIImage.init(named: "running (2)")
            bicyclingCell.styleImageVIew.image = UIImage.init(named: "solid (2)")
        case 1:
            walkingCell.styleImageVIew.image = UIImage.init(named: "walking (1)")
            runningCell.styleImageVIew.image = UIImage.init(named: "running (1)")
            bicyclingCell.styleImageVIew.image = UIImage.init(named: "solid (2)")
        case 2:
            walkingCell.styleImageVIew.image = UIImage.init(named: "walking (1)")
            runningCell.styleImageVIew.image = UIImage.init(named: "running (2)")
            bicyclingCell.styleImageVIew.image = UIImage.init(named: "solid (1)")
        default:
            break
        }
    }
    
}

extension UIViewController {
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func configureNavigationBar(){
        let backImage = UIImage(named: "arrow-left")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(popViewController))
    }
    
    @objc func popViewController() {
        if (self is UserTrackingVC){
            self.showDestructivePrompt(title: "Did you saved you run?", message: "Any unsaved data will be lost!", buttonTitle: "Ok") { _ in
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }

}

//extension for alerts
extension UIViewController {
    
    static var lightBlueColor : UIColor {
        return UIColor.init(named: "lightBlue")!
    }
    
    func showInfoMessage(message : String){
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.view.tintColor = UIViewController.lightBlueColor
        alertController.addAction(okButton)
        self.present(alertController,animated: true)
    }
    
    func showDestructivePrompt(title: String,message: String?, buttonTitle: String, handler: @escaping ((_ action: UIAlertAction) -> ())) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.view.tintColor = UIViewController.lightBlueColor
        let destroyAction = UIAlertAction(title: buttonTitle, style: .default, handler: handler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(destroyAction)
        
        self.present(alertController, animated: true)
    }
    
    func getShortStringFromDate(date : Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.MM"
        return dateFormatter.string(from: date)
    }
}


