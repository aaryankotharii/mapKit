//
//  ViewController.swift
//  tabBarViewController
//
//  Created by Aaryan Kothari on 04/02/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UITabBarControllerDelegate{

    //OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var item: UITabBarItem!
    
    //VARIABLES
    let locationManager = CLLocationManager()
    var previousLocation : CLLocation?
    var directionsArray : [MKDirections] = []
    
    
    override func viewDidLoad() {
    super.viewDidLoad()
    if self.item.tag == 1 {addressLabel.text = "move pin..."} //addressViewController
    checkLocationServicesEnables()
    }
    
    //setup location manager
    func setupLocationManager(){
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
        
    //verify location status
    func checkLocationServicesEnables(){
    if CLLocationManager.locationServicesEnabled() {
        setupLocationManager()
        checkLocationAuthorization()
    } else {
        createAlert(message: "Please Turn on Locations from settings")
            }
        }
        
    //check location authorization
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
        mapView.showsUserLocation = true
        centreViewOnUsersLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCentreLocation(for: mapView)
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

    
    
  func getCentreLocation(for mapView : MKMapView) -> CLLocation {
      let latitude = mapView.centerCoordinate.latitude
      let longitude = mapView.centerCoordinate.longitude
      return CLLocation(latitude: latitude, longitude: longitude)
  }
    
    //directions
    func getDirection(){
    guard let location = locationManager.location?.coordinate else {
        createAlert(message: "Couldnt get your location")
        return
       }
        
    let request = createDirectionsRequest(from: location)
    let directions = MKDirections(request: request)
    resetMapView(withNew: directions)
    directions.calculate { (response, error) in
        guard let response = response else { return } // response not available
        for route in response.routes {
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
           }
        }
    }
       
    
   func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
       let destinationCoordinate    =    getCentreLocation(for: mapView).coordinate
       let startingLocation         =    MKPlacemark(coordinate: coordinate)
       let destination              =    MKPlacemark(coordinate: destinationCoordinate)
       let request = MKDirections.Request()
       request.source = MKMapItem(placemark: startingLocation)
       request.destination = MKMapItem(placemark: destination)
       request.transportType = .automobile
       request.requestsAlternateRoutes = true

       return request
   }
   
    //erase previous overlays
   func resetMapView(withNew directions: MKDirections){
       mapView.removeOverlays(mapView!.overlays)
       directionsArray.append(directions)
       let _ = directionsArray.map {$0.cancel() }
   }
   
    
    @IBAction func showDirections(_ sender: Any) {    getDirection()   } //GO
    
    //Create alert function
    func createAlert(message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(action)
    }
    }


extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if self.item.tag == 0 {
            let centre = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: centre, latitudinalMeters: 5000, longitudinalMeters: 5000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {  checkLocationAuthorization()  }
}



extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let centre = getCentreLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let _ = self.previousLocation else { return }
        guard centre.distance(from: self.previousLocation!) > 50 else { return }
        self.previousLocation = centre
        
        geoCoder.reverseGeocodeLocation(centre) { [weak self] (placemarks,error) in
            guard let self = self else { return }
            if let _ = error {
                self.createAlert(message: "ERROR")
            }
            guard let placemark = placemarks?.first else { return }
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                if self.item.tag == 1 {
                    self.addressLabel.text = "\(streetNumber) \(streetName)"
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: (overlay as? MKPolyline)!)
        renderer.strokeColor = .blue
        return renderer
    }
}
