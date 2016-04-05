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
class AddLocationViewController: UIViewController,ChooseLocationTypeProtocol, UIPickerViewDataSource,UIPickerViewDelegate,MKMapViewDelegate {
    
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
    var curSpeed:Int=10;
    var typeIdChosen:Int=64;
    var direction:Double=0;

    var mapRekt:MKMapRect?
    @IBOutlet weak var addLocationMapView: MKMapView!

    @IBAction func rotateRight(sender: AnyObject) {
        let camera = self.addLocationMapView.camera
        camera.heading += 15
        self.addLocationMapView.setCamera(camera, animated: true)
    }
    
    @IBAction func rotateLeft(sender: AnyObject) {
        let camera = self.addLocationMapView.camera
        camera.heading -= 15
        self.addLocationMapView.setCamera(camera, animated: true)
    }
    @IBOutlet weak var typeImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        addLocationMapView.visibleMapRect = mapRekt!
        addLocationMapView.delegate = self

        
        
    }
    @IBAction func sendLocation(sender: AnyObject) {
        print(addLocationMapView.centerCoordinate)
        
        progressBarDisplayer("Загрузка", true)
        Alamofire.request(.POST, "http://oko.city/location/request?point.latitude=\(addLocationMapView.centerCoordinate.latitude)&point.longitude=\(addLocationMapView.centerCoordinate.longitude)&point.direction=\(direction)&point.speed=\(curSpeed)&point.radius=50.0&point.typeId=\(typeIdChosen)&point.directionType=1&extraInfo=")
            .responseJSON { _, _, result in
                print("got result \(result)")
                
                self.messageFrame.removeFromSuperview()
                self.showSimpleAlertWithTitle("Спасибо!", message: "Мы рассмотрим ваш запрос",viewController: self)
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
        typeImage.image=ImageStorage.getImage(type)
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
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("camera heading \(mapView.camera.heading)")
        direction = mapView.camera.heading
    }
    
    func showSimpleAlertWithTitle(title: String!, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(action)
        viewController.presentViewController(alert, animated: true, completion: nil)
    }

    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        curSpeed = (row + 1) * 10
        print("curSpeed is \(curSpeed)")
    }
}
