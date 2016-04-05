//
//  ImageStorage.swift
//  OKO
//
//  Created by ValKim on 3/13/16.
//  Copyright © 2016 oko. All rights reserved.
//

import Foundation
import Alamofire
import kingpin

class ImageStorage {
    //TODO add return image type
    static func getImage(typeId: Int) -> UIImage?{
        var documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        
        documentsDirectory = documentsDirectory.URLByAppendingPathComponent(String("\(typeId).png"));
        
        let checkValidation = NSFileManager.defaultManager()
        if(checkValidation.fileExistsAtPath(documentsDirectory.path!)){
            let data:NSData = NSData(contentsOfURL: documentsDirectory)!
            return UIImage(data:data)
        }else{
            
            return nil
        }
    }
    
    static func setImageViewImage(typeId: Int, annotView: MKAnnotationView){
        let typeImage = getImage(typeId)
        if(typeImage == nil){
            saveImage(typeId, annotView: annotView)
        }else{
            annotView.image = typeImage
        }
        
        
    }
    
    static func hasImage(typeId: Int) -> Bool{
        var documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        documentsDirectory = documentsDirectory.URLByAppendingPathComponent(String("\(typeId).png"));
        let checkValidation = NSFileManager.defaultManager()
        return (checkValidation.fileExistsAtPath(documentsDirectory.path!))
    }
    
    static func saveImage(typeId: Int, annotView: MKAnnotationView?) {
        if(!hasImage(typeId)){
            let urlToCall = String("http://oko.city/data/typeicon/id/\(typeId)?ptf=i&token=\(UIDevice.currentDevice().identifierForVendor!.UUIDString)")
            
            var localPath: NSURL?
            
            Alamofire.download(.GET,
                urlToCall,
                destination: { (temporaryURL, response) in
                    let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                    let pathComponent = response.suggestedFilename
                    
                    localPath = directoryURL.URLByAppendingPathComponent(pathComponent!)
                    return localPath!
            })
                .response { (request, response, _, error) in
                    
                    if(annotView != nil){
                        annotView!.image = getImage(typeId)
                    }
                    
                    print("Downloaded file \(typeId)")
                    
            }
        }
    }
}
