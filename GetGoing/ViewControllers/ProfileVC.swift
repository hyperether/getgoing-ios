//
//  ProfileVC.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/5/19.
//  Copyright © 2019 Milan Vidovic. All rights reserved.
//

import UIKit
import SwiftyPickerPopover

class ProfileVC : UIViewController {
    
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    
    var user : UserProfile = UserProfile.init(20, "Male", Date.init(), 150, 50)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user.loadFromDB()
        
        configureLabelGestures()
        configureNavigationBar()
        updateUser()
        updateDisplay()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        user.saveToDB()
    }
    
    
    
    func updateUser(){
        for run in Activities.shared.listOfRuns {
            if let distance = run.distance {
                if (user.totalDistance != nil){
                    user.totalDistance = user.totalDistance! + distance
                }
            }
            if let calories = run.calories {
                if (user.calories != nil){
                    user.calories = user.calories! + calories
                }
            }
        }
    }
    
    func configureLabelGestures(){
        let ageGesture : UIGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(onAgeLabelClick))
        ageLabel.isUserInteractionEnabled = true
        ageLabel.addGestureRecognizer(ageGesture)
        
        let genderGesture : UIGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(onGenderLabelClick))
        genderLabel.isUserInteractionEnabled = true
        genderLabel.addGestureRecognizer(genderGesture)
        
        let heightGesture : UIGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(onHeightLabelClick))
        heightLabel.isUserInteractionEnabled = true
        heightLabel.addGestureRecognizer(heightGesture)
        
        let weightGesture : UIGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(onWeightLabelClick))
        weightLabel.isUserInteractionEnabled = true
        weightLabel.addGestureRecognizer(weightGesture)
    }
    
    @objc func onAgeLabelClick(){
        let datePicker = DatePickerPopover(title: "DatePicker")
        let _ = datePicker.setDoneButton(action: { _, selectedDate in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.YYYY"
            self.user.dateOfBirth = selectedDate
            self.ageLabel.text = dateFormatter.string(from: selectedDate)
            
        })
        datePicker.appear(originView: ageLabel! as UIView, baseViewController: self)
    }
    
    
    @objc func onHeightLabelClick() {
        var ages : [String] = []
        for i in 50...250{
            ages.append("\(i)")
        }
        let stringsPicker = StringPickerPopover(title: "Height", choices: ages)
        .setSelectedRow((ages.count - 1)/2)
        .setDoneButton(action: {(popover, selectedRow, selectedString) in
            self.heightLabel.text = selectedString + "cm"
            self.user.height = Int(selectedString)
        })
        stringsPicker.appear(originView: heightLabel! as UIView, baseViewController: self)
    }
    
    @objc func onWeightLabelClick() {
        var weights : [String] = []
        for i in 50...250{
            weights.append("\(i)")
        }
        let stringsPicker = StringPickerPopover(title: "Weight", choices: weights)
            .setSelectedRow((weights.count - 1)/2)
            .setDoneButton(action: {(popover, selectedRow, selectedString) in
                self.weightLabel.text = selectedString + "kg"
                self.user.weight = Int(selectedString)
            })
        stringsPicker.appear(originView: weightLabel! as UIView, baseViewController: self)
    }
    
    
    
    @objc func onGenderLabelClick() {
        let alert = UIAlertController(title: "Select gender", message: nil, preferredStyle: .actionSheet)
        let maleButton = UIAlertAction.init(title: "Male", style: .default, handler: {_ in
            self.genderLabel.text = "Male"
            self.user.gender = "Male"
        })
        alert.addAction(maleButton)
        let femaleButton = UIAlertAction.init(title: "Female", style: .default, handler: {_ in
            self.genderLabel.text = "Female"
            self.user.gender = "Female"
        })
        alert.addAction(femaleButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateDisplay(){
        genderLabel.text = user.gender
        caloriesLabel.text = String(user.calories!) + "kcal"
        let formater = DateFormatter()
        formater.dateFormat = "dd.MM.yyyy"
        ageLabel.text = formater.string(from: user.dateOfBirth!)
        heightLabel.text = String(user.height!) + "cm"
        weightLabel.text = String(user.weight!) + "kg"
        distanceLabel.text = String(format: "%.1f", user.totalDistance!) + "m"
        
    }
}

