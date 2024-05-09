//
//  SettingsViewController.swift
//  RaceTheWind
//
//  Created by Patrick Wheeler on 5/8/24.
//  Copyright © 2024 Patrick Wheeler. All rights reserved.
//

import Foundation
import UIKit

// Implement your settings UI in this view controller. You can use Interface Builder (Storyboard or XIB) or create the UI programmatically.

class SettingsViewController: UIViewController {
    
    /*
     It's quite possible that I might want to make a SettingsManager, like BestTimesManager, so that
        A - this viewController is not in charge of any data
        B - I can singleton the SettingsManager and access it anywhere
        C - The SettingsManager can store/read the user's settings
     */
    
    var sampleSettingValue: Int = 0
    var numberOfPylons: Int = 10
    
    @IBOutlet weak var settingSlider: UISlider!
    @IBOutlet weak var numberOfPylonsLabel: UILabel!
    // I might need an outlet for the stepper
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Customize your settings view controller's UI here
        view.backgroundColor = UIColor.lightGray
        
        print("Did load a SettingsViewController")
        settingSlider.value = Float(sampleSettingValue)
    }
    override func viewDidAppear(_ animated: Bool) {
        print("DidAppear to SettingViewController")
        settingSlider.value = Float(sampleSettingValue)
    }

        // Add your settings UI elements and actions here
    
    @IBAction func didTapSettingsViewButton(_ sender: Any) {
        print("Close Button Pressed")
        dismiss(animated: true, completion: nil)
    }
    @IBAction func pylonStepperValueChanged(_ sender: UIStepper) {
        numberOfPylons = Int(sender.value)
        numberOfPylonsLabel.text = String(numberOfPylons)
    }
    
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        sampleSettingValue = Int(sender.value)
    }
    @IBAction func resetButtonPressed(_ sender: Any) {
        BestTimesManager.sharedTimesManager.resetScoresTest()
    }
    
    
    
    
}

