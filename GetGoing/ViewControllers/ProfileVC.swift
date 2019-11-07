//
//  ProfileVC.swift
//  GetGoing
//
//  Created by Milan Vidovic on 8/5/19.
//  Copyright © 2019 Hyperether LLC. All rights reserved.
//

import UIKit
import SwiftyPickerPopover

class ProfileVC : UIViewController {
    
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    
    
    @IBOutlet weak var genderStackView: UIStackView!
    @IBOutlet weak var ageStackView: UIStackView!
    @IBOutlet weak var heightStackView: UIStackView!
    @IBOutlet weak var weightStackView: UIStackView!
    
    
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    let databaseManager = DatabaseManager.instance
    var user : UserProfile = UserProfile.init(20, "Male", Date.init(), 150, 50)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedUser = databaseManager.selectUser() {
            user = selectedUser
        }
        configureLabelGestures()
        configureNavigationBar()
        updateUser()
        updateDisplay()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _ = databaseManager.insertOrUpdateUser(user: user)
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
        let ageGesture : UIGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(onAgeStackViewClick))
        ageStackView.isUserInteractionEnabled = true
        ageStackView.addGestureRecognizer(ageGesture)
        
        let genderGesture : UIGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(onGenderStackViewClick))
        genderStackView.isUserInteractionEnabled = true
        genderStackView.addGestureRecognizer(genderGesture)
        
        let heightGesture : UIGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(onHeightStackViewClick))
        heightStackView.isUserInteractionEnabled = true
        heightStackView.addGestureRecognizer(heightGesture)
        
        let weightGesture : UIGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(onWeightStackViewClick))
        weightStackView.isUserInteractionEnabled = true
        weightStackView.addGestureRecognizer(weightGesture)
    }
    
    @objc func onAgeStackViewClick(){
        let datePicker = DatePickerPopover(title: "Date")
            .setSelectedDate(user.dateOfBirth!)
            .setCancelButton(title: "Cancel", font: nil, color: UIViewController.lightBlueColor, action:nil)
        _ = datePicker.setDoneButton(title: "Done", font: nil, color: UIViewController.lightBlueColor, action: { _, selectedDate in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.YYYY"
            self.user.dateOfBirth = selectedDate
            self.ageLabel.text = dateFormatter.string(from: selectedDate)
            
        })
        datePicker.appear(originView: ageLabel! as UIView, baseViewController: self)
    }
    
    
    @objc func onHeightStackViewClick() {
        var heights : [String] = []
        for i in 50...250{
            heights.append("\(i)")
        }
        let stringsPicker = StringPickerPopover(title: "Height", choices: heights)
        .setCancelButton(title: "Cancel", font: nil, color: UIViewController.lightBlueColor, action:nil)
        .setSelectedRow(user.height! - 50)
        .setDoneButton(title: "Done", font: nil, color: UIViewController.lightBlueColor, action: {(popover, selectedRow, selectedString) in
            self.heightLabel.text = selectedString + "cm"
            self.user.height = Int(selectedString)
        })
        stringsPicker.appear(originView: heightLabel! as UIView, baseViewController: self)
    }
    
    @objc func onWeightStackViewClick() {
        var weights : [String] = []
        for i in 50...250{
            weights.append("\(i)")
        }
        let stringsPicker = StringPickerPopover(title: "Weight", choices: weights)
            .setCancelButton(title: "Cancel", font: nil, color: UIViewController.lightBlueColor, action:nil)
            .setSelectedRow(user.weight! - 50)
            .setDoneButton(title: "Done", font: nil, color: UIViewController.lightBlueColor, action: {(popover, selectedRow, selectedString) in
                self.weightLabel.text = selectedString + "kg"
                self.user.weight = Int(selectedString)
            })
        stringsPicker.appear(originView: weightLabel! as UIView, baseViewController: self)
    }
    
    
    
    @objc func onGenderStackViewClick() {
        let gender : [String] = ["Male","Female"]
        let stringsPicker = StringPickerPopover(title: "Gender", choices: gender)
        .setCancelButton(title: "Cancel", font: nil, color: UIViewController.lightBlueColor, action:nil)
        if (user.gender! == "Male"){
            _ = stringsPicker.setSelectedRow(0)
        } else {
            _ = stringsPicker.setSelectedRow(1)
        }
        _ = stringsPicker.setDoneButton(title: "Done", font: nil, color: UIViewController.lightBlueColor, action: {(popover, selectedRow, selectedString) in
            self.genderLabel.text = selectedString
            self.user.gender = selectedString
        })
        stringsPicker.appear(originView: genderLabel! as UIView, baseViewController: self)
        
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

