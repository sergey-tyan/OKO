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
    var alamofireManager : Alamofire.Manager?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForResource = 5 // seconds
        
        self.alamofireManager = Alamofire.Manager(configuration: configuration)
        
        
        
        if (userDefaults.objectForKey("mapData") == nil){
            loading = true
            self.alamofireManager!.request(.GET, "http://oko.city/data/all?ptf=i&token=\(self.getBase64UUID())").responseJSON { _, _, result in
                print(result)
                if(result.isSuccess){
                    if let locationDictionary = result.value! as? NSDictionary {
                        let placesData = NSKeyedArchiver.archivedDataWithRootObject(locationDictionary)
                        self.userDefaults.setObject(placesData, forKey: "mapData");
                        self.userDefaults.synchronize();
                        LocationsDataService.saveTypeImages()
                        self.openMapOrTutorial()
                        
                    }
                }else{
                    print("FEIL")
                    let alert = UIAlertController(title: "Ошибка", message: "Не удалось установить соединение с сервером", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)

                }
            }

        }
        
        


        // Do any additional setup after loading the view.
    }
    
    func getBase64UUID()->String{
        let uuidString = UIDevice.currentDevice().identifierForVendor!.UUIDString;
        let data = uuidString.dataUsingEncoding(NSUTF8StringEncoding)
        
        return data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let rotationAnimation:CABasicAnimation=CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue=CGFloat(M_2_PI) * 3 * 2
        rotationAnimation.duration=2
        rotationAnimation.cumulative=true
        rotationAnimation.repeatCount=3
        self.radarImageView.layer .addAnimation(rotationAnimation, forKey: "rotationAnimation")
        self.performSelector(#selector(AnimationViewController.smallAppear), withObject: self, afterDelay: 0.8)
        self.performSelector(#selector(AnimationViewController.fadeOutSmall), withObject: self, afterDelay: 0.8)
        
        var turns = 500
        if(!loading){
            turns = 5
            self.performSelector(#selector(AnimationViewController.openMapOrTutorial), withObject: self, afterDelay: 3)
        }
        for i in 0..<turns {
            self.performSelector(#selector(AnimationViewController.smallAppear), withObject: self, afterDelay: 0.8 + 3.25 * Double(i))
            self.performSelector(#selector(AnimationViewController.fadeOutSmall), withObject: self, afterDelay: 0.8 + 3.25 * Double(i))
            
            self.performSelector(#selector(AnimationViewController.bigAppear), withObject: self, afterDelay: 2.1 + 3.25 * Double(i))
            self.performSelector(#selector(AnimationViewController.fadeOutBig), withObject: self, afterDelay: 2.1 + 3.25 * Double(i))
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
    
    func openMapOrTutorial(){

        print("open Map or Tutorial")
        
        if ((userDefaults.objectForKey("show_tutorial")) != nil){
            self.performSegueWithIdentifier("openMap", sender: nil)
        }else{
            self.performSegueWithIdentifier("openTutorial", sender: nil)
        }
        
        //self.performSegueWithIdentifier("openTutorial", sender: nil)
        

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
