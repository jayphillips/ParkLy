//
//  ParkingSpot.swift
//  Park.ly
//
//  Created by Jay Phillips on 3/4/21.
//

import UIKit
import MapKit

class ParkingSpot: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
