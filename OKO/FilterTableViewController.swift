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
    var savedFilters = [Int]()
    override func viewDidLoad() {
        print("table View Loaded")
        
        if let possibleFilters = userDefaults.objectForKey("savedFilters"){
            
            savedFilters = possibleFilters as! [Int]
        }else{
            //Nothing stored in NSUserDefaults yet. Set a value.
            print("NOFILTERS")
            
            
        }
        print(savedFilters)

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("indexPath.row \(tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier)");
        let filterID = tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier as String?
        
        let startIndex = filterID!.startIndex.advancedBy(2)
        let filter = Int(filterID!.substringFromIndex(startIndex))
        print(filter)
        print(savedFilters)
        
        
        let check = tableView.cellForRowAtIndexPath(indexPath)?.viewWithTag(322) as? UIImageView
        
        let myNSString = filterID as NSString?
        myNSString!.substringWithRange(NSRange(location: 0, length: 2))
        let filterStr = myNSString as! String
        
        
        if let filterInt = Int(filterStr) {
            print("filterStr = \(filterStr)")
            if let index = savedFilters.indexOf(filterInt) {
                savedFilters.removeAtIndex(index)
                check?.image = UIImage(named: "filter-uncheck")
            }else{
                check?.image = UIImage(named: "filter-check")
                savedFilters.append(filterInt)
            }
        } else {
            print("doesnt work")
        }
        userDefaults.setObject(savedFilters, forKey: "savedFilters")
        print(savedFilters)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 14
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
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


        
        let check = cell.viewWithTag(322) as? UIImageView
        let filterID = cell.reuseIdentifier
        
        let myNSString = filterID as NSString?
        myNSString!.substringWithRange(NSRange(location: 0, length: 2))
        let filterStr = myNSString as! String
        

        
        if let filterInt = Int(filterStr) {
            print("filterStr = \(filterStr)")
            if (savedFilters.contains(filterInt)) {
                check?.image = UIImage(named: "filter-check")
            }else{
                check?.image = UIImage(named: "filter-uncheck")
            }
        } else {
            print("doesnt work")
            // handle the fact, that toInt() didn't yield an integer value
        }
        
        
        


        return cell
    }

}
