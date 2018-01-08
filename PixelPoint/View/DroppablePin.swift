//
//  DroppablePin.swift
//  PixelPoint
//
//  Created by Sohel Dhengre on 08/01/18.
//  Copyright © 2018 Sohel Dengre. All rights reserved.
//

import Foundation
import MapKit

class DroppablePin : NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String){
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
    
    
}
