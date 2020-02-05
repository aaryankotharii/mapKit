//
//  addressViewController.swift
//  Maps
//
//  Created by Aaryan Kothari on 06/02/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class addressViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var previousLocation : CLLocation?
    let annotation = MKPointAnnotation()
    
    @IBOutlet weak var addressLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServicesEnables()
        annotation.coordinate = CLLocationCoordinate2D(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        mapView.addAnnotation(annotation)
        // Do any additional setup after loading the view.
    }
    
  
        
    func setupLocationManager(){
        mapView.delegate = self
        locationManager.delegate = self as? CLLocationManagerDelegate
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
            startTrackingUserLocation()
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
    
    func startTrackingUserLocation(){
        mapView.showsUserLocation = true
        centreViewOnUsersLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCentreLocation(for: mapView)
    }
        
        func centreViewOnUsersLocation(){
            if let location = locationManager.location?.coordinate {
                let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 10000, longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
            }
            
        }
        


 

    
    
    func getCentreLocation(for mapView : MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */




extension addressViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}




extension addressViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let centre = getCentreLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        
        guard let previousLocation = self.previousLocation else { return }
        guard centre.distance(from: self.previousLocation!) > 50 else { return }
        self.previousLocation = centre
        
        geoCoder.reverseGeocodeLocation(centre) { [weak self] (placemarks,error) in
            guard let self = self else { return }
            
            if let _ = error {
                //error
            }
            guard let placemark = placemarks?.first else {
                //inform user
                return
            }
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
        }
    }
}
