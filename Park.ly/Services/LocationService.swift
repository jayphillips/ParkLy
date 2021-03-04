//
//  LocationService.swift
//  Park.ly
//
//  Created by Jay Phillips on 2/15/21.
//

import Foundation
import CoreLocation

protocol CustomUserLocationDelegate {
    func userLocationUpdated(location: CLLocation)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    
    static let instance = LocationService()
    
    var customUserLocationDelege: CustomUserLocationDelegate?
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locationManager.location?.coordinate
        
        if customUserLocationDelege != nil {
            customUserLocationDelege?.userLocationUpdated(location: locations.first!)
        }
    }
}
