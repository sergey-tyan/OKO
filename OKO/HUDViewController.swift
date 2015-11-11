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

    @IBOutlet weak var viewToFlip: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        hudLabel.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        

        // Do any additional setup after loading the view.
        
        //TODO Отразить слева направо
        viewToFlip.transform = CGAffineTransformMakeScale(1.0, -1.0)
    }

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var speedSignImageView: UIImageView!
    @IBOutlet weak var signImageView: UIImageView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil);
    }

    @IBOutlet weak var speedLabel: UILabel!
    

    
    func locationTriggered(location:Location){
        signImageView.image=UIImage(named:location.imageName)
        speedSignImageView.hidden = false
        if(location.imageName.containsString("limit")){
            speedSignImageView.hidden=true
        }
        if(location.speed < 40){
            speedSignImageView.image = UIImage(named:"speed-limit-40")
        }else if(location.speed >= 40 && location.speed < 50){
            speedSignImageView.image = UIImage(named:"speed-limit-50")
        }else if(location.speed >= 50 && location.speed < 60){
            speedSignImageView.image = UIImage(named:"speed-limit-60")
        }else if(location.speed >= 60 && location.speed < 80){
            speedSignImageView.image = UIImage(named:"speed-limit-80")
        }else{
            speedSignImageView.hidden=true
        }
        distanceLabel.text = String(format: "%.0f м", location.distance)
        signImageView.hidden = false

        distanceLabel.hidden = false

    }
    
    func clearLabels(){
        signImageView.hidden = true
        speedSignImageView.hidden = true
        distanceLabel.hidden = true
        
    }
    
    func updateSpeed(location:CLLocation){
        var speedDouble = location.speed * 3.6;
        if(speedDouble < 0){
            speedDouble = 0;
        }
        speedLabel.text = NSString(format: "%.0f", speedDouble) as String
    }

    /*
        Setting to Landscape Mode and disabling autorotation
    */
    override func shouldAutorotate() -> Bool {
        return false;
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeRight;
    }
    

}
