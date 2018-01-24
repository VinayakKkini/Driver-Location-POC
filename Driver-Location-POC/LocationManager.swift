//
//  LocationManager.swift
//  Driver-Location-POC
//
//  Created by Vinayak Kini on 12/28/17.
//  Copyright © 2017 Vinayak Kini. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject {
    private let locationManager = CLLocationManager()
    var locationUpdate: (([CLLocation]) -> Void)?
    
    override init()  {
        super.init()
        setup()
    }
    
    var permissionStatus: CLAuthorizationStatus {
        return  CLLocationManager.authorizationStatus()
    }
    
    private func setup() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    func askPermission() {
        switch permissionStatus {
        case .authorizedAlways: break
        case .notDetermined:// ask permisiion
            locationManager.requestWhenInUseAuthorization()
            fallthrough
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        case .denied: // open settings for the user to enable it
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        default: break
        }
    }
    
    func trackLocation() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        locationUpdate?(locations)
    }
}
