//
//  LocationsStorage.swift
//  OKO
//
//  Created by ValKim on 3/21/16.
//  Copyright © 2016 oko. All rights reserved.
//

import Foundation
import Alamofire

class LocationsDataService {
    static let userDefaults = NSUserDefaults.standardUserDefaults()

    
    static func saveTypeImages(){
       if let savedData = userDefaults.objectForKey("mapData") as? NSData{
            let placesDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(savedData) as? NSDictionary
            if let types = placesDictionary?.objectForKey("types") as? NSArray {
                for type in types{
                    let typeID = type.objectForKey("id") as! Int
                    ImageStorage.saveImage(typeID)
                    print(typeID)
                }
            }
        }
    }
}