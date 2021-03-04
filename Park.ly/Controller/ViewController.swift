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
    @IBOutlet weak var parkButton: RoundButton!
    @IBOutlet weak var directionsButton: RoundButton!
    
    let locationManager = CLLocationManager()
    
    var parkedCarAnnotation: ParkingSpot?

    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthorizationStatus()
        mapView.delegate = self
        directionsButton.isEnabled = false
        setupLongPress()
    }
    
    @IBAction func resetMapCenter(sender: RoundButton) {
        guard let coordinate = LocationService.instance.currentLocation else { return }
        centerMapOnUserLocation(coordinates: coordinate)
    }
    
    @IBAction func parkedButtonTapped(sender: RoundButton) {
        mapView.removeAnnotations(mapView.annotations)
        guard let coordinates = LocationService.instance.currentLocation else { return }
        if parkedCarAnnotation == nil {
            setupAnnotation(coordinate: coordinates)
            parkButton.setImage(#imageLiteral(resourceName: "foundCar"), for: .normal)
            directionsButton.isEnabled = true
        } else {
            //TODO: handle removing annotation
            parkButton.setImage(#imageLiteral(resourceName: "parkCar"), for: .normal)
            parkedCarAnnotation = nil
            directionsButton.isEnabled = false
            removeOverLays()
            centerMapOnUserLocation(coordinates: coordinates)
        }
    }
    
    @IBAction func getDirectionsTapped(sender: RoundButton) {
        guard let userCoordinates = LocationService.instance.currentLocation,
             let parkedCar = parkedCarAnnotation else { return }
        getDirectionsToCar(userCoordinates: userCoordinates, parkedCarCoordinate: parkedCar.coordinate)
    }
}

extension ViewController: MKMapViewDelegate {
    
    func checkLocationAuthorizationStatus() {
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            self.mapView.showsUserLocation = true
            LocationService.instance.customUserLocationDelege = self
        } else {
            LocationService.instance.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapOnUserLocation(coordinates: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapView.setRegion(region, animated: true)
    }
    
    func setupAnnotation(coordinate: CLLocationCoordinate2D) {
        parkedCarAnnotation = ParkingSpot(title: "We parked here", subtitle: "Tap for directions", coordinate: coordinate)
        mapView.addAnnotation(parkedCarAnnotation!)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ParkingSpot {
            let id = "pin"
            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.canShowCallout = true
            view.animatesDrop = true
            view.pinTintColor = .red
            view.calloutOffset = CGPoint(x: -8, y: -3)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let coordinates = LocationService.instance.currentLocation,
        let parkedCar = parkedCarAnnotation else { return }
        getDirectionsToCar(userCoordinates: coordinates, parkedCarCoordinate: parkedCar.coordinate)
        view.setSelected(false, animated: true)
    }
}

extension ViewController: CustomUserLocationDelegate {
    func userLocationUpdated(location: CLLocation) {
        centerMapOnUserLocation(coordinates: location.coordinate)
    }
    
    
}

extension ViewController {
    func setupLongPress() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPress.minimumPressDuration = 0.75
        self.mapView.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        mapView.removeAnnotations(mapView.annotations)
        if gesture.state == .ended {
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            setupAnnotation(coordinate: coordinate)
            
            directionsButton.isEnabled = true
            parkButton.setImage(#imageLiteral(resourceName: "foundCar"), for: .normal)
        }
    }
    
}

extension ViewController {
    func getDirectionsToCar(userCoordinates: CLLocationCoordinate2D, parkedCarCoordinate: CLLocationCoordinate2D) {
        
        removeOverLays()
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinates))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: parkedCarCoordinate))
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard let route = response?.routes.first else { return }
            self.mapView.addOverlay(route.polyline)
            
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 200, left: 50, bottom: 50, right: 50), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let directionsRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        directionsRenderer.lineWidth = 5
        directionsRenderer.alpha = 0.85
        directionsRenderer.strokeColor = .blue
        return directionsRenderer
    }
    
    func removeOverLays() {
        self.mapView.overlays.forEach({ self.mapView.removeOverlay($0)})
    }
}
