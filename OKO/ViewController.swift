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


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, KPClusteringControllerDelegate {
    @IBOutlet weak var distanceBottom: UILabel!
    @IBOutlet weak var bottomInfoBar: UIView!
    @IBOutlet weak var signImageBottom: UIImageView!
    @IBOutlet weak var descriptionBottom: UILabel!

    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var centerOnUserButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var signSpeedLimitBottom: UILabel!
    @IBOutlet var compasView: UIImageView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var menuView: UIView!
    
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
    var typeArray = [LocationType]()
    var allLocationDictionary =  [Int:[Location]]()
    var activeFilters:[Int] = [61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72]
    var curSpeedColor: Int = 0
    var userLocation:CLLocation=CLLocation()
    var lastUserLocationForMapLoading:CLLocation=CLLocation()
    
    var delegate:MyLocationDelegateProtocol?=nil
    var progressBarShowing:Bool=false
    @IBOutlet var speedLabel: UILabel!
    private var clusteringController : KPClusteringController!
    var buttonBeep : AVAudioPlayer?
    
    let locationShowRadius:Double = 2000.0
    
/*
View Appearance
************************************************************************************************************
*/
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let buttonBeep = self.setupAudioPlayerWithFile("sound_alarm", type:"mp3") {
            self.buttonBeep = buttonBeep
        }

        //let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        //centerMapOnLocation(initialLocation)
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.translucent = true
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
        mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
        if #available(iOS 9.0, *) {
            mapView.showsCompass=false
        } else {
            // Fallback on earlier versions
        };

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enterBackground", name: "appEntersBackground", object: nil)
        locationManager.startUpdatingLocation()
        

        
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
    
    override func viewDidAppear(animated: Bool) {
        print("viewDidAppear")
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        


        //self.menuView.frame.origin.x = ((-1) * self.menuView.frame.width)
    }
    override func viewWillAppear(animated: Bool) {
        print("VIEW WILL APPEAR!")
        
        self.groupLocationsByType()
        
    }
    
    func groupLocationsByType(){
        if let possibleFilters = userDefaults.objectForKey("savedFilters"){
            
            activeFilters = possibleFilters as! [Int]
            print("HAS FILTERS \(activeFilters)")
        }else{
            //Nothing stored in NSUserDefaults yet. Set a value.
            
            userDefaults.setObject(activeFilters, forKey: "savedFilters")
            print("LOADED NEW FILTERS \(activeFilters)")
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
    
    
    @IBAction func toggleMenu(sender: AnyObject) {
        if(self.menuView.hidden){
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
                    self.menuView.hidden = true
                }
                
        })
    }
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
/*
************************************************************************************************************
*/

    
/*
Location Manager Delegate Methods
************************************************************************************************************
*/

    @IBAction func openHud(sender: AnyObject) {
        self.performSegueWithIdentifier("openHud", sender: self)
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

    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {

        print("newHeading =\(newHeading.magneticHeading)")
        /*var headingDegrees:CGFloat = (heading*M_PI/180.0); //assuming needle points to top of iphone. convert to radians
        compasView.transform = CGAffineTransformMakeRotation(headingDegrees);*/
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        userLocation = locations.last!;

        if let savedData = userDefaults.objectForKey("mapData") as? NSData{
            loadDataFromMemory(savedData,currentCoordinate: userLocation)
        }else{
            
            startSaving()
        }


        //UPDATE COURSE AND SPEED HERE
        delegate?.updateSpeed(userLocation)

//        print("locationUpdated \(UIApplication.sharedApplication().keyWindow!.rootViewController?.classForCoder)")
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
            

//            mapView.setRegion(MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan()), animated: false)
            mapView.setCamera(newCamera, animated: false)

            var newSpeedColor:Int;
            if(speed >= 0 && speed < 60){
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
/*      print("curSpeedColor = \(curSpeedColor)")
        print("course = \(course)")
        print("speed = \(speed)")*/

        speedLabel.text = NSString(format: "%.2f", speed) as String
        
        /////////////////////////////////
        var locationsAroundUser = [Location]()
        var locationAnnotationDict = [Location:MKAnnotation]()
        if(working){
            stopMonitoringGeotification()
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

            //ищем первую точку, расстояние до которой меньше 700 м по направлению
            for nearestLoc in sortedLocationsAroundUser{

                //угол между ближайшей точкой и локейшном юзера
                let locToUserAngle = bearingBetweenTwoPoints(nearestLoc.coordinate.latitude,
                    lon1: nearestLoc.coordinate.longitude,
                    lat2: userLocation.coordinate.latitude,
                    lon2: userLocation.coordinate.longitude)
                
                let userToLocAngle = bearingBetweenTwoPoints(userLocation.coordinate.latitude,
                    lon1: userLocation.coordinate.longitude,
                    lat2: nearestLoc.coordinate.latitude,
                    lon2: nearestLoc.coordinate.longitude)

                //направление точки минус угол
                let degree = abs(nearestLoc.direction - locToUserAngle)
                
                let degree2 = abs(course - userToLocAngle)
                
                if((nearestLoc.distance < 200)/* TODO UNCOMMENT && (degree < 30) && (degree2 < 30)*/){
                    if let triggeredAnnotation = locationAnnotationDict[nearestLoc]{
                        delegate?.locationTriggered(nearestLoc)
                        buttonBeep?.play()
                        sendPush()
                        if(mapView.viewForAnnotation(triggeredAnnotation)?.frame.size.height == 20){
                            mapView.selectAnnotation(triggeredAnnotation, animated: true)

                            print("happy")
                        }
                    }else{
                        print("disasta")
                    }
                    print("distance: \(nearestLoc.distance)")
                    print("direction: \(nearestLoc.direction)")
                    print("locToUserAngle: \(locToUserAngle)")
                    print("degree: \(degree)")
                    break
                }else{
                    delegate?.clearLabels()
                }
            }
        }
    }
    
    func alertUser(alertLocation: Location){
        showSimpleAlertWithTitle("distance \(alertLocation.distance)", message: "\(alertLocation.imageName)", viewController: self)
    }

    func deselectAllAnnotations(){
        print("deselecting")
        for annotation in mapView.annotations{
            mapView.deselectAnnotation(annotation, animated: false)
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
                    annotationView.image=UIImage(named: "claster")
                    annotationView.frame=CGRectMake(0,0,30,30);
                    return annotationView
                }
            }
            else {
                
                let kpAnnot = annotation as? KPAnnotation
                let kpSet = kpAnnot?.annotations;
                
                let locationAnnot = kpSet?.first as! Location
                //let userLocation = mapView.userLocation
                
                //let loc1CLLocation = CLLocation(latitude: locationAnnot.coordinate.latitude, longitude: locationAnnot.coordinate.longitude)
                //let userCLLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
                //let dist1 = userCLLocation.distanceFromLocation(loc1CLLocation)
                //print(locationAnnot.imageName)
                //print("dist1 \(dist1)")
                a.title = "angle \(locationAnnot.direction)"
                
                //TODO добавить нормальную картинку для направления
                let asd:UIImageView=UIImageView(image: UIImage(named:"ic_normal_yes"))
                asd.tag = 1
            
                let headingDegrees:CGFloat = CGFloat((locationAnnot.direction)*M_PI/180.0);

                asd.transform = CGAffineTransformMakeRotation(headingDegrees)
                if let reusedAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin"){
                    reusedAnnotationView.image=UIImage(named: locationAnnot.imageName)
                    reusedAnnotationView.frame=CGRectMake(0,0,20,20);
                    reusedAnnotationView.viewWithTag(1)?.removeFromSuperview()
                    reusedAnnotationView.addSubview(asd)
                    asd.center=reusedAnnotationView.center
                    return reusedAnnotationView
                }else{
                    let newAnnotationView = MKAnnotationView(annotation: a, reuseIdentifier: "pin")
                    newAnnotationView.image=UIImage(named: locationAnnot.imageName)
                    newAnnotationView.frame=CGRectMake(0,0,20,20);
                    newAnnotationView.canShowCallout = true;
                    newAnnotationView.addSubview(asd)
                    asd.center=newAnnotationView.center
                    return newAnnotationView
                }
            }
            
        }
        
        return nil;
    }
    
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("refreshing")
        clusteringController.refresh(true)
        print("finished refreshing")
        
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
                
            }
        }
        
        selectLocationIcon(view)
    }

    func selectLocationIcon(view: MKAnnotationView){
        if view.annotation is KPAnnotation {
            let cluster = view.annotation as! KPAnnotation
            
            if cluster.annotations.count == 1 {
                if(view.frame.size.height == 20){
                
                    UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
                        view.frame=CGRectMake(view.frame.origin.x-10,view.frame.origin.y-10,40,40);
                        }, completion: { finished in
                    })
                    let kpSet = cluster.annotations;
                    let locationAnnot = kpSet?.first as! Location
                    print("imageName \(locationAnnot.imageName)")
                    bottomInfoBar.hidden = false
                    let loc1CLLocation = CLLocation(latitude: locationAnnot.coordinate.latitude, longitude: locationAnnot.coordinate.longitude)
                    distanceBottom.text = NSString(format: "%.0f", userLocation.distanceFromLocation(loc1CLLocation)) as String
                    signImageBottom.image = UIImage(named: locationAnnot.imageName)
                    descriptionBottom.text = locationAnnot.signDescription
                    signSpeedLimitBottom.text = NSString(format: "%.0f km/h", locationAnnot.speed) as String
                
                }
            }
        }
    
    }
    
    func deselectLocationIcon(view:MKAnnotationView){
        if view.annotation is KPAnnotation {
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
                view.frame=CGRectMake(view.frame.origin.x+10,view.frame.origin.y+10,20,20);
                }, completion: { finished in
            })
        }

    }
    
    
    
    
    
/*
************************************************************************************************************
*/

    
    
/*
Map Buttons IBActions
************************************************************************************************************
*/

    
    @IBAction func zoomIn(sender: AnyObject) {

        if(!working){
            var region = mapView.region;
            print("latitudeDelta \(region.span.latitudeDelta)")
            print("longitudeDelta \(region.span.longitudeDelta)")
            var span = MKCoordinateSpan();
            span.latitudeDelta = region.span.latitudeDelta/2;
            span.longitudeDelta = region.span.longitudeDelta/2;

            region.span = span;
            mapView.setRegion(region, animated: true);
        }
    }
    @IBAction func zoomOut(sender: AnyObject) {
        if(!working){
            mapView.setUserTrackingMode(MKUserTrackingMode.None, animated: true);
            var region = mapView.region;
            var span = MKCoordinateSpan()
            print("latitudeDelta \(region.span.latitudeDelta)")
            print("longitudeDelta \(region.span.longitudeDelta)")
            
            if(region.span.longitudeDelta < 50){
                span.latitudeDelta = region.span.latitudeDelta*2;
                span.longitudeDelta = region.span.longitudeDelta*2;
                
                region.span = span;
                mapView.setRegion(region, animated: true);
            }
        }
    }
      
    @IBAction func startDetecting(sender: AnyObject) {
        if(!working){
            centerOnUser(sender)
            speedIndicator.hidden=false;
            radarButton.selected = true;
            print("switched ON")

//            mapView.setUserTrackingMode(MKUserTrackingMode.None, animated: true);

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
            speedIndicator.hidden=true;
            radarButton.selected = false;
            mapView.setUserTrackingMode(MKUserTrackingMode.None, animated: true);
            mapView.zoomEnabled = true;
            mapView.scrollEnabled = true;
            mapView.userInteractionEnabled = true;
            stopMonitoringGeotification()
            speedColor.image = UIImage(named:"slow-speed")
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

        let newCamera = mapView.camera
        newCamera.centerCoordinate = userLocation.coordinate
        newCamera.altitude=1000.0
        mapView.setCamera(newCamera, animated: false)

        let info = String("locationManager.monitoredRegions.count = \(locationManager.monitoredRegions.count) and mapView.annotations.count = \(mapView.annotations.count)")
        print(info)
    

    }
    
/*
************************************************************************************************************
*/

    
    
/*
    API methods
************************************************************************************************************
*/
    
    
    func startSaving() {
        if(!progressBarShowing){
            progressBarShowing = true
            progressBarDisplayer("Загрузка", true)


            Alamofire.request(.GET, "http://scl.kz/data/all")
                .responseJSON { _, _, result in
    //                print("JSON \(result.value!)")
                    print("got result")
                    if let locationDictionary = result.value! as? NSDictionary {
                        let placesData = NSKeyedArchiver.archivedDataWithRootObject(locationDictionary)
                        self.userDefaults.setObject(placesData, forKey: "mapData");
                        self.userDefaults.synchronize();
    //                    self.loadDataFromMemory(placesData)
    //                    self.groupLocationsByType()
                        self.messageFrame.removeFromSuperview()
                        self.progressBarShowing = false
                        
                    }
            }
        }
    }
    
    func loadDataFromMemory(savedData:NSData, currentCoordinate:CLLocation){
        print("loading data from memory \(userLocation.coordinate)")

        
        let placesDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(savedData) as? NSDictionary
        
        if(currentCoordinate.distanceFromLocation(lastUserLocationForMapLoading) > locationShowRadius - 100.0){
            
            if let types = placesDictionary?.objectForKey("types") as? NSArray {
                for type in types{
                    let newType = LocationType(name:type.objectForKey("name") as! String,id:type.objectForKey("id") as! Int);
                    typeArray.append(newType)
                }
            }
            if let locations  = placesDictionary?.objectForKey("locations") as? NSArray {
                locationArray = [Location]()
                for location in locations{
                    let type = location.objectForKey("typeId") as! Int;
                    let newLocation = Location(typeInt:type,
                        speed: location.objectForKey("speed") as! Double)
                    newLocation.coordinate = CLLocationCoordinate2DMake(location.objectForKey("latitude") as! Double,
                        location.objectForKey("longitude") as! Double)
                    newLocation.direction = location.objectForKey("direction") as! Double
                    newLocation.radius = location.objectForKey("radius") as! Double
                    let IdInt = location.objectForKey("id") as! Int
                    newLocation.identifier = String(format:"\(IdInt)")
                    let loc1CLLocation = CLLocation(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
                    let dist1 = userLocation.distanceFromLocation(loc1CLLocation)
                    newLocation.distance = dist1
                    locationArray.append(newLocation)
                }
                lastUserLocationForMapLoading = currentCoordinate
                locationArray = locationArray.sort(sortFunc)
                print("allLocationDictionary")
                print(allLocationDictionary)
                
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
                print("allLocationDictionary after")
                print(allLocationDictionary)
            }

            print("allLocationDictionary \(allLocationDictionary.count)")
        }
    }
    /*
    FUNCTION TO STOP MONITORING GEOTIFICATIONS
*/
    
    func stopMonitoringGeotification() {
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion {
                locationManager.stopMonitoringForRegion(circularRegion)
            }
        }
    }
    
    func showSimpleAlertWithTitle(title: String!, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(action)
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            region.identifier
            print("triggered phantom geofencing")
        }
    }
    
    
    func toggleInfoSpeedBar(){
        bottomInfoBar.hidden = !bottomInfoBar.hidden
        speedIndicator.hidden = !speedIndicator.hidden
    }
    
/*
************************************************************************************************************
*/

    func clusteringControllerShouldClusterAnnotations(clusteringController: KPClusteringController!) -> Bool {
        let region = mapView.region;
        
            
        //Проверяем зум карты и если слишком близко то отключаем кластеризацию
        if(working && region.span.latitudeDelta < 0.09){
            return false
        }
        
        if(region.span.latitudeDelta < 0.05){
            print("DONT CLUSTER")
            //return false
            
        }
        
        return true
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
    
    override func shouldAutorotate() -> Bool {
        return false;
    } 
    @IBAction func openFacebook(sender: AnyObject) {
        print("fb")
        let facebookURL = (NSURL(string: "fb://profile/G8YNICqAwTE")!)
        if(!UIApplication.sharedApplication().openURL(facebookURL)){
            UIApplication.sharedApplication().openURL((NSURL(string: "https://www.facebook.com/okosw")!))
        }
    }
    @IBAction func openTwitter(sender: AnyObject) {

        
        let twitterURL = (NSURL(string: "twitter:///user?screen_name=OK0SW")!)
        if(!UIApplication.sharedApplication().openURL(twitterURL)){
            UIApplication.sharedApplication().openURL((NSURL(string: "https://www.twitter.com/OK0SW")!))
        }
    }

    @IBAction func openVk(sender: AnyObject) {

        
        UIApplication.sharedApplication().openURL(NSURL(string: "vk://vk.com/okosw")!)
        
        let vkURL = (NSURL(string: "vk://vk.com/okosw")!)
        if(!UIApplication.sharedApplication().openURL(vkURL)){
            UIApplication.sharedApplication().openURL((NSURL(string: "https://vk.com/okosw")!))
        }

    }
    @IBAction func openInstagram(sender: AnyObject) {

        
        let instagramURL = (NSURL(string: "instagram://user?username=okosw")!)
        if(!UIApplication.sharedApplication().openURL(instagramURL)){
            UIApplication.sharedApplication().openURL((NSURL(string: "https://instagram.com/okosw")!))
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
        localNotification.alertBody = "Осторожно, 100 м до ближайшей опасности!"
        localNotification.region = CLCircularRegion(center:locationCoord , radius: 100, identifier: id)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    
    func sendPush(){
        
        
        let localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertBody = "Осторожно, 100 м до ближайшей опасности!"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 0)
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.soundName =  "out.caf"

        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }

    
    // app enters background
    
    var inBackground:Bool = false
    
    func enterBackground() {
        print("APP ENTERS BACKGROUND")
        inBackground = true
        var counter = 0
/*        if(working){
            for someLocation in nearestLocationsArray{
                if(counter < 20){
                    counter++
                    sendLocalPush(someLocation.coordinate,id: String("id \(counter)"))
                    print("adding local pushes id \(counter)")
                }
            }
        }
*/
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait;
    }
}

