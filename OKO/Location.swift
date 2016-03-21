//
//  Location.swift
//  OKO
//
//  Copyright (c) 2015 oko. All rights reserved.
//

import Foundation
import UIKit
import MapKit



class Location:NSObject, MKAnnotation{
    
    var direction:Double = 0.0
    var speed:Double = 0.0
    var radius:Double = 0.0
    var imageName:String = ""
    var typeInt:Int = 0
    var identifier:String = ""
    var coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var distance:Double = 0.0
    var signDescription:String = ""
    var directionType:Int = 0
    var extraInfo:String = ""
    
    init(typeInt:Int, speed: Double) {
        
        self.speed = speed
        self.typeInt = typeInt;
/*        switch self.typeInt {
        case 61:
            imageName="another-danger"
            signDescription="Другая опасность"
            
        case 62:
            imageName="mobile-camera-ambush"
            signDescription="Автомобиль ДПС в засаде"
        case 63:
            imageName="static-speed-camera"
            signDescription = "Статическая камера, измеряющая скорость"
        case 64:
            switch speed{
            case 40:
                imageName="speed-limit-40"
                signDescription = "Ограничение скорости 40 км/ч"
            case 50:
                imageName="speed-limit-50"
                signDescription = "Ограничение скорости 50 км/ч"
            case 60:
                imageName="speed-limit-60"
                signDescription = "Ограничение скорости 60 км/ч"
            case 80:
                imageName="speed-limit-80"
                signDescription = "Ограничение скорости 80 км/ч"
            default:
                imageName="speed-limit-40"
                signDescription = "Ограничение скорости 40 км/ч"
            }
            
            
        case 65:
            imageName="sleeping-policeman"
            signDescription = "Лежачий полицейский"
        case 66:
            imageName="danger-route-change"
            signDescription = "Опасное изменение направления движения"
        case 67:
            imageName="danger-crossway"
            signDescription = "Опасный перекрёсток"
        case 68:
            imageName="svetofor-camera"
            signDescription = "Камера, встроенная в светофор"
        case 69:
            imageName="red-light-camera"
            signDescription = "Камера, проверяющая проезд на красный свет"
        case 70:
            imageName="trenoga"
            signDescription = "Мобильная камера, трехножка"
        case 71:
            imageName="bad-road"
            signDescription = "Плохая дорога"
        case 72:
            imageName="another-danger"
            signDescription = "Другая опасность"
        default:
            imageName="another-danger"
            signDescription = "Другая опасность"
        }*/
        
        super.init()
    }

    override init(){
        super.init()
    }
    
    func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
}

