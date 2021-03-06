//
//  LocaionTypeTableViewController.swift
//  OKO
//
//  Created by Aider on 30.10.15.
//  Copyright © 2015 oko. All rights reserved.
//

import UIKit

class LocaionTypeTableViewController: UITableViewController {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var delegate:ChooseLocationTypeProtocol?=nil
    var typeArray = [LocationType]()
    let cellIdentifier = "LocationTypeTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        if let savedData = userDefaults.objectForKey("mapData") as? NSData{
            let placesDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(savedData) as? NSDictionary
            if let types = placesDictionary?.objectForKey("types") as? NSArray {
                for type in types{
                    let description = type.objectForKey("description") as! String
                    let typeID = type.objectForKey("id") as! Int
                    let type = LocationType(description: description, id: typeID)
                    typeArray.append(type)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return typeArray.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

/*        var locationType:Int = 0
        
        switch indexPath.row {
            case 0:locationType = 70
                
            case 1:locationType = 63
            case 2:locationType = 68
            case 3:locationType = 69
            case 4:locationType = 62
            case 5:locationType = 64 //40
            case 6:locationType = 64 //50
            case 7:locationType = 64 //60
            case 8:locationType = 64 //80
            case 9:locationType = 65
            case 10:locationType = 71
            case 11:locationType = 66
            case 12:locationType = 67
            case 13:locationType = 61
            default: 61
            
        }
        
        delegate?.typeChosen(locationType)
        self.dismissViewControllerAnimated(true, completion: nil);*/
        
        let selectedType = typeArray[indexPath.row]
        delegate?.typeChosen(selectedType.id)
        self.dismissViewControllerAnimated(true, completion: nil);

    }
    
    

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /*
        var cell :UITableViewCell
        
        
        switch indexPath.row {
        case 0:cell = tableView.dequeueReusableCellWithIdentifier("70", forIndexPath: indexPath)
            
        case 1:cell = tableView.dequeueReusableCellWithIdentifier("63", forIndexPath: indexPath)
        case 2:cell = tableView.dequeueReusableCellWithIdentifier("68", forIndexPath: indexPath)
        case 3:cell = tableView.dequeueReusableCellWithIdentifier("69", forIndexPath: indexPath)
        case 4:cell = tableView.dequeueReusableCellWithIdentifier("62", forIndexPath: indexPath)
        case 5:cell = tableView.dequeueReusableCellWithIdentifier("64 40", forIndexPath: indexPath)
        case 6:cell = tableView.dequeueReusableCellWithIdentifier("64 50", forIndexPath: indexPath)
        case 7:cell = tableView.dequeueReusableCellWithIdentifier("64 60", forIndexPath: indexPath)
        case 8:cell = tableView.dequeueReusableCellWithIdentifier("64 80", forIndexPath: indexPath)
        case 9:cell = tableView.dequeueReusableCellWithIdentifier("65", forIndexPath: indexPath)
        case 10:cell = tableView.dequeueReusableCellWithIdentifier("71", forIndexPath: indexPath)
        case 11:cell = tableView.dequeueReusableCellWithIdentifier("66", forIndexPath: indexPath)
        case 12:cell = tableView.dequeueReusableCellWithIdentifier("67", forIndexPath: indexPath)
        case 13:cell = tableView.dequeueReusableCellWithIdentifier("61", forIndexPath: indexPath)
        default: cell = tableView.dequeueReusableCellWithIdentifier("61", forIndexPath: indexPath)
            
        }
        return cell */
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! LocationTypeTableViewCell
        
        let currentType = typeArray[indexPath.row]
        cell.typeImageView.image = ImageStorage.getImage(currentType.id)
        cell.descriptionLabel.text = currentType.description
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 80.0;//Choose your custom row height
    }

    

    

}
