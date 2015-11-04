//
//  HUDViewController.swift
//  OKO
//
//  Created by Aider on 04.10.15.
//  Copyright © 2015 oko. All rights reserved.
//

import UIKit
import CoreLocation

class HUDViewController: UIViewController,MyLocationDelegateProtocol {

    @IBOutlet weak var hudLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        hudLabel.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil);
    }

    @IBOutlet weak var speedLabel: UILabel!

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {





    }
    
    func updateSpeed(location:CLLocation){
        var speedDouble = location.speed * 3.6;
        if(speedDouble < 0){
            speedDouble = 0;
        }
        speedLabel.text = NSString(format: "%.0f", speedDouble) as String
        print("delegate updated")
    }

    /*
        Setting to Landscape Mode and disabling autorotation
    */
    override func shouldAutorotate() -> Bool {
        return false;
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape;
    }
    

}
