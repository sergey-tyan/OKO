//
//  SettingsViewController.swift
//  OKO
//
//  Created by Aider on 28.11.15.
//  Copyright © 2015 oko. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    let userDefaults = NSUserDefaults.standardUserDefaults()
    override func viewDidLoad() {
        super.viewDidLoad()

        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var trafficSwitch: UISwitch!

    @IBOutlet weak var backgroundSwitch: UISwitch!
    @IBOutlet weak var distanceLabel: UILabel!
    
    // MARK: - Navigation

    @IBAction func sliderValuseChanged(sender: AnyObject) {
        distanceLabel.text = NSString(format: "%.0f м", slider.value) as String
    }
    
    override func viewWillAppear(animated: Bool) {
        if ((userDefaults.objectForKey("trigger_radius")) != nil){
            slider.value = userDefaults.objectForKey("trigger_radius") as! Float
            distanceLabel.text = NSString(format: "%.0f м", slider.value) as String
        }

        
        if ((userDefaults.objectForKey("show_traffic")) != nil){
            trafficSwitch.on = userDefaults.objectForKey("show_traffic") as! Bool
        }
        
        if ((userDefaults.objectForKey("background_work")) != nil){
            backgroundSwitch.on = userDefaults.objectForKey("background_work") as! Bool
        }

    }
    
    @IBAction func back(sender: AnyObject) {
        self.userDefaults.setBool(trafficSwitch.on, forKey: "show_traffic")
        self.userDefaults.setBool(backgroundSwitch.on, forKey: "background_work")
        self.userDefaults.setFloat(slider.value, forKey: "trigger_radius")
        self.userDefaults.synchronize();
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
