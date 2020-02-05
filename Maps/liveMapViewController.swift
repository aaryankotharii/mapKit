//
//  ViewController.swift
//  Maps
//
//  Created by Aaryan Kothari on 04/02/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class liveMapViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServicesEnables()
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func checkLocationServicesEnables(){
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
        else{
            let alert = UIAlertController(title: "Error", message: "Please Turn on Locations from settings", preferredStyle: .alert)
            let action = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(action)
        }
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
        mapView.showsUserLocation = true
        centreViewOnUsersLocation()
        locationManager.startUpdatingLocation()
        break
        case .denied:
        break
        case .notDetermined:
        locationManager.requestWhenInUseAuthorization()
        break
        case .restricted:
        break
        case .authorizedAlways:
        break
        @unknown default:
            fatalError()
        }
    }
    
    func centreViewOnUsersLocation(){
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 10000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
        
    }
    


}


extension liveMapViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let centre = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: centre, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

