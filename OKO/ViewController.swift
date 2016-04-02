//
//  ViewController.swift
//  OKO
//
//  Created by Пользователь on 15.08.15.
//  Copyright (c) 2015 oko. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import kingpin
import AVFoundation


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, KPClusteringControllerDelegate,UIScrollViewDelegate {
    @IBOutlet weak var distanceBottom: UILabel!
    @IBOutlet weak var bottomInfoBar: UIView!
    @IBOutlet weak var signImageBottom: UIImageView!
    @IBOutlet weak var descriptionBottom: UILabel!

    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var centerOnUserButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var confirmationView: UIView!
    @IBOutlet weak var signSpeedLimitBottom: UILabel!
    @IBOutlet var compasView: UIImageView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var notSeenImageView: UIImageView!
    @IBOutlet weak var seenImageView: UIImageView!
    
    @IBOutlet weak var speedColor: UIImageView!
    
    @IBOutlet weak var speedIndicator: UIView!
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    var menuOpened = false
    
    @IBOutlet weak var radarButton: UIButton!
    var working = false
    let regionRadius: CLLocationDistance = 1000
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let locationManager = CLLocationManager()

    var locationArray = [Location]()
    var filteredLocationArray = [Location]()
    var nearestLocationsArray = [Location]()
    var allLocationDictionary =  [Int:[Location]]()
    var activeFilters:[Int] = [61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72]
    var curSpeedColor: Int = 0
    var userLocation:CLLocation=CLLocation()
    var lastUserLocationForMapLoading:CLLocation=CLLocation()
    var selectedLocationID:String?
    @IBOutlet weak var soundSwitch: UISwitch!
    var delegate:MyLocationDelegateProtocol?=nil
    var progressBarShowing:Bool=false
    @IBOutlet var speedLabel: UILabel!
    private var clusteringController : KPClusteringController!
    var buttonBeep : AVAudioPlayer?
    
    var showTraffic:Bool=false
    var workInBackground:Bool=true
    var inBackground:Bool = false
    
    //Расстояние, в радиусе которого подгружаются точки.
    let locationShowRadius:Double = 2000.0
    
    //Расстояние до объекта, при котором выводится предупреждение (в метрах)
    var triggerRadius:Double = 120.0
    //Угол, под которым камера видит машину и машина видит камеру
    let sightDegree:Double = 30
    
    let notificationText:String="Осторожно, 100 м до ближайшей опасности!"
    
    var menuToggled:Bool = false
    
/*
View Appearance
************************************************************************************************************
*/
    
    @IBOutlet weak var menuScrollView: UIScrollView!
    
    @IBOutlet weak var menuInsideView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let buttonBeep = self.setupAudioPlayerWithFile("sound_alarm", type:"mp3") {
            self.buttonBeep = buttonBeep
        }
        
        Alamofire.request(.GET, "http://oko.city/ios/version")
            .responseJSON { request, response, result in
            print("ALALALA")
            let version = result.value as! Double
            print(version)
            if(version > 1.0){
                self.showSimpleAlertWithTitle("Вышла новая версия", message: "Пожалуйста, обновите приложение", viewController: self)
            }
            
        }
        
        
        //FOR CLEAN START
//        userDefaults.removeObjectForKey("mapData");

        selectedLocationID = nil
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.translucent = true
        menuScrollView.delegate=self

        //initially hiding 
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        print("viewDidLoad")
        let algorithm : KPGridClusteringAlgorithm = KPGridClusteringAlgorithm()
        
        algorithm.annotationSize = CGSizeMake(20, 20)
        algorithm.gridSize = CGSizeMake(50, 50);
        algorithm.clusteringStrategy = KPGridClusteringAlgorithmStrategy.TwoPhase;
        
        clusteringController = KPClusteringController(mapView: self.mapView, clusteringAlgorithm: algorithm)
        clusteringController.delegate = self
        
        //self.menuView.hidden = true
        
        mapView.delegate = self;
        mapView.showsUserLocation=true;

        if #available(iOS 9.0, *) {
            mapView.showsCompass=false
        }
    
        



        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.enterBackground), name: "appEntersBackground", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.becomeActive), name: "appBecomesActive", object: nil)
        locationManager.startUpdatingLocation()
        

        
    }
    
    override func viewDidLayoutSubviews() {
        menuScrollView.contentSize=menuInsideView.frame.size
        
    }

    
   
    
    func progressBarDisplayer(msg:String, _ indicator:Bool ) {
        print("SHOW ACTIVITY VIEW")
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
    
    override func viewDidAppear(animated: Bool) {
        print("viewDidAppear")
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        if ((userDefaults.objectForKey("trigger_radius")) != nil){
            triggerRadius = userDefaults.objectForKey("trigger_radius") as! Double
        }
        print("trigger radius \(triggerRadius)")
        
        if ((userDefaults.objectForKey("show_traffic")) != nil){
            showTraffic = userDefaults.objectForKey("show_traffic") as! Bool
        }
        print("showTraffic \(showTraffic)")
        
        
        if ((userDefaults.objectForKey("background_work")) != nil){
            workInBackground = userDefaults.objectForKey("background_work") as! Bool
        }
        print("workInBackground \(workInBackground)")

    }
    
    override func viewWillAppear(animated: Bool) {
        print("VIEW WILL APPEAR")
        self.groupLocationsByType()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "openHud"){
            let vc = segue.destinationViewController as! HUDViewController
            self.delegate = vc
        }
        if(segue.identifier == "addSign"){
            let vc = segue.destinationViewController as! AddLocationViewController
            vc.mapRekt = mapView.visibleMapRect
            print(mapView.visibleMapRect)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false;
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
    }



    
    
    

    
    //Application Logic
    //
    func groupLocationsByType(){
        if let possibleFilters = userDefaults.objectForKey("savedFilters"){
            activeFilters = possibleFilters as! [Int]
        }else{
            //Nothing stored in NSUserDefaults yet. Set a value.
            userDefaults.setObject(activeFilters, forKey: "savedFilters")
        }
        filteredLocationArray = [Location]()
        for someType in allLocationDictionary.keys {
            print("type code: \(someType)")
            if(activeFilters.contains(someType)){
                let currentFilteredLocationArray = allLocationDictionary[someType] as [Location]!
                for oneLoc in currentFilteredLocationArray {
                    filteredLocationArray.append(oneLoc)
                }
            }
        }
        self.clusteringController.setAnnotations(filteredLocationArray)
        self.clusteringController.refresh(true)
    }
    
    
    func clusteringControllerShouldClusterAnnotations(clusteringController: KPClusteringController!) -> Bool {
        let region = mapView.region;
        
        
        //Проверяем зум карты и если слишком близко то отключаем кластеризацию
        if(working && region.span.latitudeDelta < 0.09){
            return false
        }
        
        return true
    }
    

    
    /*
    Location Manager Delegate Methods
    ************************************************************************************************************
    */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if((inBackground && workInBackground) || (!inBackground)){
            userLocation = locations.last!;
            if let savedData = userDefaults.objectForKey("mapData") as? NSData{
                loadLocationsAroundUser(savedData,currentCoordinate: userLocation)
            }else{
                
                startSaving()
            }


            //UPDATE COURSE AND SPEED HERE
            delegate?.updateSpeed(userLocation)
            var speed = userLocation.speed;
            let course = userLocation.course

            speed = speed * 3.6;
            

            
            if(speed < 0){
                speed = 0;
                curSpeedColor = 0
            }

            if(working){
                let newCamera = mapView.camera
                if(course > 0){
                    newCamera.heading=course
                }else{
                    newCamera.heading=0.0
                }
                
                newCamera.centerCoordinate = userLocation.coordinate
                mapView.setCamera(newCamera, animated: false)

                var newSpeedColor:Int;
                if(speed < 5){
                    newSpeedColor = 1
                }
                else if(speed >= 5 && speed < 60){
                    newSpeedColor = 1
                } else if(speed < 80){
                    newSpeedColor = 2
                }else{
                    newSpeedColor = 3
                }
                if(curSpeedColor != newSpeedColor){
                    curSpeedColor = newSpeedColor
                    switch(curSpeedColor){
                    case 0:
                        speedColor.image = UIImage(named:"slow-speed")
                        break;
                    case 1:
                        speedColor.image = UIImage(named:"normal-speed")
                        break;
                    case 2:
                        speedColor.image = UIImage(named:"fast-speed")
                        break
                    case 3:
                        speedColor.image = UIImage(named:"danger-speed")
                        break;
                    default:
                        speedColor.image = UIImage(named:"slow-speed")
                        break;
                    }
                }
            }
            speedLabel.text = NSString(format: "%.0f", speed) as String
            var locationsAroundUser = [Location]()
            var locationAnnotationDict = [Location:MKAnnotation]()
            if(working){
                let annotations = mapView.annotations
                //В этом цикле берутся все точки вокруг пользователя не в кластерах и добавляются в массив
                for annotation in annotations{
                    if annotation is KPAnnotation {
                        let a = annotation as! KPAnnotation
                        if (!a.isCluster()) {
                            let kpAnnot = annotation as? KPAnnotation
                            let kpSet = kpAnnot?.annotations;
                            let locationAnnot = kpSet?.first as! Location
                            let loc1CLLocation = CLLocation(latitude: locationAnnot.coordinate.latitude, longitude: locationAnnot.coordinate.longitude)
                            let dist1 = userLocation.distanceFromLocation(loc1CLLocation)
                            locationAnnot.distance = dist1
                            locationsAroundUser.append(locationAnnot)
                            locationAnnotationDict[locationAnnot] = annotation

                        }
                    }
                }
                //локейшны вокруг пользователя сортируются по дистанции к нему
                let sortedLocationsAroundUser = locationsAroundUser.sort(sortFunc)
                
                for nearestLoc in sortedLocationsAroundUser{
                    //угол между ближайшей точкой и локейшном юзера
                    let locToUserAngle = bearingBetweenTwoPoints(nearestLoc.coordinate.latitude,
                        lon1: nearestLoc.coordinate.longitude,
                        lat2: userLocation.coordinate.latitude,
                        lon2: userLocation.coordinate.longitude)
                    //угол между юзером и точкой
                    let userToLocAngle = bearingBetweenTwoPoints(userLocation.coordinate.latitude,
                        lon1: userLocation.coordinate.longitude,
                        lat2: nearestLoc.coordinate.latitude,
                        lon2: nearestLoc.coordinate.longitude)

                    //направление точки минус угол
                    var degree = abs(nearestLoc.direction - locToUserAngle)
                    let degree2 = abs(course - userToLocAngle)
                    
                    
                    //TODO Протестировать
                    //если камера смотрит в обе стороны
                    if(nearestLoc.directionType == 2){
                        //если машина не попадает в обзор первого направления, то проверяем второе направление
                        if(degree > sightDegree){
                            var secondDirection = nearestLoc.direction + 180.0;
                            if(secondDirection > 360.0){
                                secondDirection -= 360.0;
                            }
                            
                            degree = abs(secondDirection - locToUserAngle)
                        }
                    }
                    
                    if((nearestLoc.distance > triggerRadius - 20.0) && (nearestLoc.distance < triggerRadius) && (degree < sightDegree) && (degree2 < sightDegree)){
                        if let triggeredAnnotation = locationAnnotationDict[nearestLoc]{
                            delegate?.locationTriggered(nearestLoc)
                            if(soundSwitch.on){
                                buttonBeep?.play()
                            }
                            if(inBackground){
                                sendPush()
                            }
                            mapView.selectAnnotation(triggeredAnnotation, animated: true)
                        }
                        break
                    }else{
                        delegate?.clearLabels()
                    }
                }
            }
        }
    }
    

    func deselectAllAnnotations(){
        for annotation in mapView.annotations{
            if !(annotation is MKUserLocation){
                mapView.deselectAnnotation(annotation, animated: false)
            }
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "user")
            annotationView.image = UIImage(named:"user")
            return annotationView
        }
        if annotation is KPAnnotation {
            let a = annotation as! KPAnnotation
            if a.isCluster() {
                if let reusedClasterAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("cluster"){
                    return reusedClasterAnnotationView
                }else{
                    let annotationView = MKAnnotationView(annotation: a, reuseIdentifier: "cluster")
                    annotationView.image=UIImage(named: "cluster")
                    annotationView.frame=CGRectMake(0,0,30,30);
                    return annotationView
                }
            }
            else {
                
                let kpAnnot = annotation as? KPAnnotation
                let kpSet = kpAnnot?.annotations;
                
                let locationAnnot = kpSet?.first as! Location
                //a.title = "angle \(locationAnnot.direction)"
                var directionImageName = "direction"
                if(locationAnnot.directionType == 2){
                    directionImageName = "direction2"
                }
                
                let directionImageView:UIImageView=UIImageView(image: UIImage(named:directionImageName))
                directionImageView.tag = 1

                let headingDegrees:CGFloat = CGFloat((locationAnnot.direction)*M_PI/180.0);
                directionImageView.transform = CGAffineTransformMakeRotation(headingDegrees)
                if let reusedAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin"){
                    reusedAnnotationView.image=ImageStorage.getImage(locationAnnot.typeInt)
                    reusedAnnotationView.frame=CGRectMake(0,0,20,20);
                    reusedAnnotationView.viewWithTag(1)?.removeFromSuperview()
                    reusedAnnotationView.addSubview(directionImageView)
                    directionImageView.center=reusedAnnotationView.center
                    return reusedAnnotationView
                }else{
                    let newAnnotationView = MKAnnotationView(annotation: a, reuseIdentifier: "pin")
                    newAnnotationView.image=ImageStorage.getImage(locationAnnot.typeInt)!
                    newAnnotationView.frame=CGRectMake(0,0,20,20);
                    newAnnotationView.addSubview(directionImageView)
                    directionImageView.center=newAnnotationView.center
                    return newAnnotationView
                }
            }
        }
        return nil;
    }
    
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        clusteringController.refresh(true)
        
        self.menuView.hidden = !menuToggled
        
        let headingDegrees:CGFloat = CGFloat((360.0-mapView.camera.heading)*M_PI/180.0);
        compasView.transform=CGAffineTransformMakeRotation(headingDegrees)
        

        for annotation in mapView.annotations{
            if annotation is KPAnnotation {
                let a = annotation as! KPAnnotation
                if (!a.isCluster()) {
                    let kpAnnot = annotation as? KPAnnotation
                    let kpSet = kpAnnot?.annotations;
                    let locationAnnot = kpSet?.first as! Location
                    let locationDegrees:CGFloat = CGFloat((360.0-mapView.camera.heading + locationAnnot.direction)*M_PI/180.0);
                    mapView.viewForAnnotation(annotation)?.viewWithTag(1)?.transform=CGAffineTransformMakeRotation(locationDegrees)
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        bottomInfoBar.hidden = true
        confirmationView.hidden = true
        selectedLocationID = nil
        deselectLocationIcon(view)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if view.annotation is KPAnnotation {
            let cluster = view.annotation as! KPAnnotation
            if cluster.annotations.count > 1 {
                let region = MKCoordinateRegionMakeWithDistance(cluster.coordinate,
                    cluster.radius * 2.5,
                    cluster.radius * 2.5)
                mapView.setRegion(region, animated: true)
            }else{
                selectLocationIcon(view)
            }
        }
    }

    func selectLocationIcon(view: MKAnnotationView){
        if view.annotation is KPAnnotation {
            let cluster = view.annotation as! KPAnnotation
            
            if cluster.annotations.count == 1 {
                if(view.frame.size.height == 20){
                
                    UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
                        view.frame=CGRectMake(view.frame.origin.x-10,view.frame.origin.y-10,40,40);
                        let directionImage = view.viewWithTag(1)! as! UIImageView
                        directionImage.center=CGPoint(x: 20, y: 20)
                        }, completion: { finished in
                            

                    })
                    
                    
                    let kpSet = cluster.annotations;
                    let locationAnnot = kpSet?.first as! Location
                    print("image type \(locationAnnot.typeInt)")
                    bottomInfoBar.hidden = false
                    confirmationView.hidden = false
                    let loc1CLLocation = CLLocation(latitude: locationAnnot.coordinate.latitude, longitude: locationAnnot.coordinate.longitude)
                    distanceBottom.text = NSString(format: "%.0f", userLocation.distanceFromLocation(loc1CLLocation)) as String
                    signImageBottom.image = ImageStorage.getImage(locationAnnot.typeInt)!
                    descriptionBottom.text = locationAnnot.signDescription
                    signSpeedLimitBottom.text = NSString(format: "%.0f km/h", locationAnnot.speed) as String
                    selectedLocationID = locationAnnot.identifier
                }
            }
        }
    
    }
    
    func deselectLocationIcon(view:MKAnnotationView){
        if view.annotation is KPAnnotation {
            let cluster = view.annotation as! KPAnnotation
            
            if cluster.annotations.count == 1 {
                UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
                    view.frame=CGRectMake(view.frame.origin.x+10,view.frame.origin.y+10,20,20);
                    
                    let directionImage = view.viewWithTag(1)! as! UIImageView

                    directionImage.center=CGPoint(x: 10, y: 10)

                    }, completion: { finished in

                })
            }
        }

    }
    
/*
Map Buttons IBActions
************************************************************************************************************
*/
    
    @IBAction func openHud(sender: AnyObject) {
        self.performSegueWithIdentifier("openHud", sender: self)
    }

    
    @IBAction func zoomIn(sender: AnyObject) {
        if(!working){
            let newCamera = mapView.camera
            newCamera.centerCoordinate = userLocation.coordinate
            newCamera.altitude=mapView.camera.altitude / 2
            mapView.setCamera(newCamera, animated: true)
        }
    }
    @IBAction func zoomOut(sender: AnyObject) {
        if(!working){
            let newCamera = mapView.camera
            newCamera.centerCoordinate = userLocation.coordinate
            newCamera.altitude=mapView.camera.altitude * 2
            mapView.setCamera(newCamera, animated: true)
        }
    }
      
    @IBAction func startDetecting(sender: AnyObject) {
        if(!working){
            print("switched ON")
            centerOnUser(sender)
            speedIndicator.hidden=false;
            radarButton.selected = true;
            mapView.zoomEnabled = false;
            mapView.scrollEnabled = false;
            mapView.userInteractionEnabled = false;
            zoomInButton.hidden=true
            zoomOutButton.hidden=true
            centerOnUserButton.hidden=true
            
        }else{
            print("switched OFF")
            deselectAllAnnotations()
            bottomInfoBar.hidden = true
            confirmationView.hidden = true
            speedIndicator.hidden=true;
            radarButton.selected = false;
            mapView.setUserTrackingMode(MKUserTrackingMode.None, animated: true);
            mapView.zoomEnabled = true;
            mapView.scrollEnabled = true;
            mapView.userInteractionEnabled = true;
            zoomInButton.hidden=false
            zoomOutButton.hidden=false
            centerOnUserButton.hidden=false

            
        }
        working = !working
    }
    @IBAction func refreshDatabase(sender: AnyObject) {
        print("start saving")

        startSaving()
        print("stop saving")
    }

    
    
    @IBAction func centerOnUser(sender: AnyObject) {
        print(soundSwitch.on)

        let newCamera = mapView.camera
        newCamera.centerCoordinate = userLocation.coordinate
        newCamera.altitude=1000.0
        mapView.setCamera(newCamera, animated: false)
        let info = String("locationManager.monitoredRegions.count = \(locationManager.monitoredRegions.count) and mapView.annotations.count = \(mapView.annotations.count)")
        print(info)
    }

    
    
/*
    API functions
************************************************************************************************************
*/
    
    
    func startSaving() {
        if(!progressBarShowing){
            progressBarShowing = true
            progressBarDisplayer("Загрузка", true)
            
            Alamofire.request(.GET, "http://oko.city/data/all?ptf=i&token=\(self.getBase64UUID())")
                .responseJSON { _, _, result in
    //                print("JSON \(result.value!)")
                    print("got result")
                    if let locationDictionary = result.value! as? NSDictionary {
                        let placesData = NSKeyedArchiver.archivedDataWithRootObject(locationDictionary)
                        self.userDefaults.setObject(placesData, forKey: "mapData");
                        self.userDefaults.synchronize();
    //                    self.loadDataFromMemory(placesData)
    //                    self.groupLocationsByType()
                        
                        LocationsDataService.saveTypeImages()
                        
                        self.messageFrame.removeFromSuperview()
                        self.progressBarShowing = false
                        
                    }
            }
        }
    }
    
    func loadLocationsAroundUser(savedData:NSData, currentCoordinate:CLLocation){
//        print("checking if need to load new data around \(userLocation.coordinate)")
        
        if(currentCoordinate.distanceFromLocation(lastUserLocationForMapLoading) > locationShowRadius - 100.0){
            let placesDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(savedData) as? NSDictionary
            let typeDictionary:NSMutableDictionary = NSMutableDictionary()
            
            if let types = placesDictionary?.objectForKey("types") as? NSArray {
                for type in types{
                    let description = type.objectForKey("description") as! String
                    let typeID = type.objectForKey("id") as! Int
                    typeDictionary.setObject(description, forKey: typeID)
                }
            }
            if let locations  = placesDictionary?.objectForKey("locations") as? NSArray {
                locationArray = [Location]()
                for location in locations{
                    let type = location.objectForKey("typeId") as! Int;
                    let newLocation = Location(typeInt:type,
                        speed: location.objectForKey("speed") as! Double)
                    newLocation.signDescription = typeDictionary.objectForKey(type) as! String
                    newLocation.coordinate = CLLocationCoordinate2DMake(location.objectForKey("latitude") as! Double,
                        location.objectForKey("longitude") as! Double)
                    newLocation.direction = location.objectForKey("direction") as! Double
                    newLocation.radius = location.objectForKey("radius") as! Double
                    newLocation.directionType = location.objectForKey("directionType") as! Int
                    let IdInt = location.objectForKey("id") as! Int
                    newLocation.identifier = String(format:"\(IdInt)")
                    let loc1CLLocation = CLLocation(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
                    let dist1 = userLocation.distanceFromLocation(loc1CLLocation)
                    newLocation.distance = dist1
                    locationArray.append(newLocation)
                }
                lastUserLocationForMapLoading = currentCoordinate
                locationArray = locationArray.sort(sortFunc)

                for someLocation in locationArray{
                    if(someLocation.distance < locationShowRadius){
                        nearestLocationsArray.append(someLocation)
                        if var arrayForType = allLocationDictionary[someLocation.typeInt]{
                            arrayForType.append(someLocation)
                            allLocationDictionary[someLocation.typeInt]=arrayForType
                        }else{
                            var newArrayForType = [Location]()
                            newArrayForType.append(someLocation)
                            allLocationDictionary[someLocation.typeInt]=newArrayForType
                        }
                    }
                }
                groupLocationsByType()
            }
        }
    }
    
    
    //
    //Help functions
    //

    func getBase64UUID()->String{
        let uuidString = UIDevice.currentDevice().identifierForVendor!.UUIDString;
        let data = uuidString.dataUsingEncoding(NSUTF8StringEncoding)
        
        return data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
    }
    
    
    @IBAction func notseenTouchDown(sender: AnyObject) {
        notSeenImageView.highlighted = true
    }
    
    @IBAction func seenTouchDown(sender: AnyObject) {
        seenImageView.highlighted = true
    }
    @IBAction func confirm(sender: AnyObject) {
        print("confirm \(selectedLocationID)")
        seenImageView.highlighted = false
        
        //POST /location/seen/{locationId}
        
        if(selectedLocationID != nil){
            let postURL = "http://oko.city/location/seen/\(selectedLocationID!)?ptf=i&token=\(self.getBase64UUID())"
            print(postURL)
            Alamofire.request(.POST, postURL)
                .response { request, response, data, error in
                    print(response?.statusCode)
                    self.showSimpleAlertWithTitle("Спасибо", message: "Голос засчитывается только 1 раз", viewController: self)
                    
            }
        }
        
        
    }
    
    @IBAction func dontConfirm(sender: AnyObject) {
        print("dont confirm \(selectedLocationID)")
        notSeenImageView.highlighted = false
        
        if(selectedLocationID != nil){
            let postURL = "http://oko.city/location/unseen/\(selectedLocationID!)?ptf=i&token=\(self.getBase64UUID())"
            print(postURL)
            Alamofire.request(.POST, postURL as String!)
                .response { request, response, data, error in
                    print(response?.statusCode)
                    self.showSimpleAlertWithTitle("Спасибо", message: "Голос засчитывается только 1 раз", viewController: self)
                    
            }
                    
            
            
        }
    }
    func toggleInfoSpeedBar(){
        bottomInfoBar.hidden = !bottomInfoBar.hidden
        speedIndicator.hidden = !speedIndicator.hidden
    }
    

    func showSimpleAlertWithTitle(title: String!, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(action)
        viewController.presentViewController(alert, animated: true, completion: nil)
    }

    
    
    func sortFunc(loc1: Location, loc2: Location) -> Bool {
        return loc1.distance < loc2.distance
    }
    
    func bearingBetweenTwoPoints( lat1 : Double,  lon1 : Double,  lat2 : Double,  lon2: Double) -> Double {
        func DegreesToRadians (value:Double) -> Double {
            return value * M_PI / 180.0
        }
        
        func RadiansToDegrees (value:Double) -> Double {
            return value * 180.0 / M_PI
        }
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        let value = RadiansToDegrees(radiansBearing);
        if(value > 0){
            return value
        }else{
            return 360.0 + value
        }
    }
    
    @IBAction func toggleMenu(sender: AnyObject) {
        print("togg")
        menuToggled = self.menuView.hidden
        if(self.menuView.hidden){
            menuToggled = true
            self.menuView.frame.origin.x = ((-1) * self.menuView.frame.width)
            self.menuView.hidden = false
        }
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            if(self.menuOpened){
                self.menuView.frame.origin.x = ((-1) * self.menuView.frame.width)
            }else{
                self.menuView.frame.origin.x = 0
            }
            self.menuOpened = !self.menuOpened
            }, completion: { finished in
                if(!self.menuOpened){
                    self.menuView.hidden = false
                }
            }
        )
    }

    
    @IBAction func openFacebook(sender: AnyObject) {
        print("fb")
        //TODO FACEBOOK PROFILE
        let facebookURL = (NSURL(string: "fb://profile/G8YNICqAwTE")!)
        if(!UIApplication.sharedApplication().openURL(facebookURL)){
            UIApplication.sharedApplication().openURL((NSURL(string: "https://www.facebook.com/oko.city")!))
        }
    }
    @IBAction func openTwitter(sender: AnyObject) {

        
        let twitterURL = (NSURL(string: "twitter:///user?screen_name=ok0city")!)
        if(!UIApplication.sharedApplication().openURL(twitterURL)){
            UIApplication.sharedApplication().openURL((NSURL(string: "https://twitter.com/ok0city")!))
        }
    }

    @IBAction func openVk(sender: AnyObject) {


        
        let vkURL = (NSURL(string: "vk://vk.com/oko.city")!)
        if(!UIApplication.sharedApplication().openURL(vkURL)){
            UIApplication.sharedApplication().openURL((NSURL(string: "https://vk.com/oko.city")!))
        }

    }
    @IBAction func openInstagram(sender: AnyObject) {
        let instagramURL = (NSURL(string: "instagram://user?username=oko.city")!)
        if(!UIApplication.sharedApplication().openURL(instagramURL)){
            UIApplication.sharedApplication().openURL((NSURL(string: "https://www.instagram.com/oko.city")!))
        }
    }
    @IBAction func AddNewRoadsign(sender: AnyObject) {
        self.performSegueWithIdentifier("addSign", sender: self)
    }
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
        //1
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        
        //2
        var audioPlayer:AVAudioPlayer?
        
        // 3
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
    }
    
    func sendLocalPush(locationCoord:CLLocationCoordinate2D,id:String){
        let localNotification:UILocalNotification = UILocalNotification()
        localNotification.regionTriggersOnce = true
        localNotification.alertBody = notificationText
        localNotification.region = CLCircularRegion(center:locationCoord , radius: 100, identifier: id)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    
    func sendPush(){
        let localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertBody = notificationText
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 0)
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.soundName =  "out.caf"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    // app enters background
    func enterBackground() {
        print("APP ENTERS BACKGROUND")
        inBackground = true
    }
    
    func becomeActive() {
        print("APP BECAME ACTIVE")


        inBackground = false
    }
    
}

