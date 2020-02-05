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

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}


extension MapScreen : CLLocationManagerDelegate {
    didupdate
}

