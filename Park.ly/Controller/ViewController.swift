//
//  ViewController.swift
//  Park.ly
//
//  Created by Jay Phillips on 2/15/21.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        mapView.delegate = self
    }


}

extension ViewController: MKMapViewDelegate {
    func checkLoacationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.mapView.showsUserLocation = true
        } else {
            LocationService.instance.locationManager.requestWhenInUseAuthorization()
        }
    }
}
