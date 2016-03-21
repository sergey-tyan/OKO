//
//  FilterTableViewController.swift
//  OKO
//
//  
//  Copyright (c) 2015 oko. All rights reserved.
//

import UIKit

class FilterTableViewController: UITableViewController {
    
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var typeArray = [LocationType]()
    var savedFilters = [Int]()
    let cellIdentifier = "LocationTypeTableViewCell"
    override func viewDidLoad() {
        print("table View Loaded")

        if let possibleFilters = userDefaults.objectForKey("savedFilters"){
            
            savedFilters = possibleFilters as! [Int]
        }else{
            //Nothing stored in NSUserDefaults yet. Set a value.
            print("NOFILTERS")
        }
        
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

        
        print(typeArray)

    }
    
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let cell = tableView.cellForRowAtIndexPath(indexPath) as! LocationTypeTableViewCell

        let selectedType = typeArray[indexPath.row]
        
        let filter = selectedType.id
        print(filter)
        print(savedFilters)

        if let index = savedFilters.indexOf(filter) {
            savedFilters.removeAtIndex(index)
            cell.checkedImageView.image = UIImage(named: "filter-uncheck")
        }else{
            cell.checkedImageView.image = UIImage(named: "filter-check")
            savedFilters.append(filter)
        }
        userDefaults.setObject(savedFilters, forKey: "savedFilters")
        print(savedFilters)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeArray.count
    }
    

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! LocationTypeTableViewCell
        
        let currentType = typeArray[indexPath.row]
        cell.typeImageView.image = ImageStorage.getImage(currentType.id)
        cell.descriptionLabel.text = currentType.description
        if (savedFilters.contains(currentType.id)) {
            cell.checkedImageView.image = UIImage(named: "filter-check")
        }else{
            cell.checkedImageView.image = UIImage(named: "filter-uncheck")
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 80.0;//Choose your custom row height
    }

}
