//
//  AnimationViewController.swift
//  OKO
//
//  Created by Aider on 13.11.15.
//  Copyright © 2015 oko. All rights reserved.
//

import UIKit
import QuartzCore
import Alamofire

class AnimationViewController: UIViewController {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var loading:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if (userDefaults.objectForKey("mapData") == nil){
            loading = true
            Alamofire.request(.GET, "http://scl.kz/data/all")
                .responseJSON { _, _, result in
                    //                print("JSON \(result.value!)")
                    print("got result")
                    if let locationDictionary = result.value! as? NSDictionary {
                        let placesData = NSKeyedArchiver.archivedDataWithRootObject(locationDictionary)
                        self.userDefaults.setObject(placesData, forKey: "mapData");
                        self.userDefaults.synchronize();
                        self.openMap()
                    }}

        }
        
        


        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        let rotationAnimation:CABasicAnimation=CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue=CGFloat(M_2_PI) * 3 * 2
        rotationAnimation.duration=2
        rotationAnimation.cumulative=true
        rotationAnimation.repeatCount=3
        self.radarImageView.layer .addAnimation(rotationAnimation, forKey: "rotationAnimation")
        self.performSelector("smallAppear", withObject: self, afterDelay: 0.8)
        self.performSelector("fadeOutSmall", withObject: self, afterDelay: 0.8)
        
        var turns = 500.0
        if(!loading){
            turns = 5.0
            self.performSelector("openMap", withObject: self, afterDelay: 3)
        }
        for (var i = 0.0; i < turns; i++){
            self.performSelector("smallAppear", withObject: self, afterDelay: 0.8 + 3.25 * i)
            self.performSelector("fadeOutSmall", withObject: self, afterDelay: 0.8 + 3.25 * i)
            
            self.performSelector("bigAppear", withObject: self, afterDelay: 2.1 + 3.25 * i)
            self.performSelector("fadeOutBig", withObject: self, afterDelay: 2.1 + 3.25 * i)
        }

    }
    
    
    
    
    func smallAppear(){
        self.smallPointImageView.alpha = 1
    }
    
    func bigAppear(){
        self.bigPointImageView.alpha = 1
    }
    
    func fadeOutSmall(){
        UIView.animateWithDuration(1, animations: {
            self.smallPointImageView.alpha=0
        })
    }
    
    func fadeOutBig(){
        UIView.animateWithDuration(1, animations: {
            self.bigPointImageView.alpha=0
        })
    }
    
    func openMap(){
        self.performSegueWithIdentifier("openMap", sender: nil)
    }

    
    @IBOutlet weak var bigPointImageView: UIImageView!
    @IBOutlet weak var smallPointImageView: UIImageView!
    
    @IBOutlet weak var radarImageView: UIImageView!
//
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
