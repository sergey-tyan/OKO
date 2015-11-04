//
//  AddLocationViewController.swift
//  OKO
//
//  Created by Aider on 30.10.15.
//  Copyright © 2015 oko. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
class AddLocationViewController: UIViewController,ChooseLocationTypeProtocol, UIPickerViewDataSource,UIPickerViewDelegate {
    
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var pickerViewContainer: UIView!
    
    @IBAction func doneSelectingSpeed(sender: AnyObject) {
        
        self.pickerViewContainer.hidden = true
        self.speedLabel.text = ("ОГРАНИЧЕНИЕ СКОРОСТИ \(self.curSpeed) КМ/ЧАС")
        print("curSpeed is \(self.curSpeed)")
    }
    
/*
    POST http://scl.kz/location/manual?point.latitude=43.2553616&
    point.longitude=76.863055&
    point.direction=90.0&
    point.speed=60.0&
    point.radius=50.0&
    point.typeId=69
*/
    var newLocation:Location?;
    var curSpeed:Int=10;
    var typeIdChosen:Int=64;

    var mapRekt:MKMapRect?
    @IBOutlet weak var addLocationMapView: MKMapView!

    @IBOutlet weak var typeImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        addLocationMapView.visibleMapRect = mapRekt!

        // Do any additional setup after loading the view.
    }
    @IBAction func sendLocation(sender: AnyObject) {
        print(addLocationMapView.centerCoordinate)
        
        progressBarDisplayer("Загрузка", true)
        Alamofire.request(.POST, "http://scl.kz/location/manual?point.latitude=\(addLocationMapView.centerCoordinate.latitude)&point.longitude=\(addLocationMapView.centerCoordinate.longitude)&point.direction=0&point.speed=\(curSpeed)&point.radius=50.0&point.typeId=\(typeIdChosen)")
            .responseJSON { _, _, result in
                //                print("JSON \(result.value!)")
                print("got result \(result)")
                self.messageFrame.removeFromSuperview()
        }
        

        
    }

    @IBAction func editSpeed(sender: AnyObject) {
        self.pickerViewContainer.hidden = false

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier=="chooseType"){
            let vc = segue.destinationViewController as! LocaionTypeTableViewController
            vc.delegate = self

            
        }
    }
    
    func typeChosen(type: Int) {

        newLocation = Location(typeInt: type, speed: 60)
        typeImage.image=UIImage(named: newLocation!.imageName)
        typeIdChosen = type
        
        
    }


    @IBAction func chooseType(sender: AnyObject) {
        self.performSegueWithIdentifier("chooseType", sender: self)
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 9
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String("\((row + 1) * 10) км/ч")
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func progressBarDisplayer(msg:String, _ indicator:Bool ) {
        print("SHOW PROGRESS BAR")
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.whiteColor()
        messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 180, height: 50))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        if indicator {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        view.addSubview(messageFrame)
    }

    override func shouldAutorotate() -> Bool {
        return false;
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        curSpeed = (row + 1) * 10
        print("curSpeed is \(curSpeed)")
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
