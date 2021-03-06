//
//  MyLocationDelegateProtocol.swift
//  OKO
//
//  Created by Aider on 04.10.15.
//  Copyright © 2015 oko. All rights reserved.
//

import UIKit
import CoreLocation

protocol MyLocationDelegateProtocol {
    func updateSpeed(location:CLLocation)
    func locationTriggered(location:Location)
    func clearLabels()

}

protocol ChooseLocationTypeProtocol {
    func typeChosen(type:Int)
    
}

