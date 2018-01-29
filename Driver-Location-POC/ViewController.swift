//
//  ViewController.swift
//  Driver-Location-POC
//
//  Created by Vinayak Kini on 12/28/17.
//  Copyright © 2017 Vinayak Kini. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet private(set) var mapView: MKMapView!
    private var locationManager = LocationManager()
    private let annotationIdentifier = "CarAnnotationIdentifier"
    private let socket = Socket()
    var oldLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        socket.setupNetworkCommunication()
        socket.join(username: "Dummy Driver")
        locationManager.askPermission()
        locationManager.trackLocation()
        locationManager.locationUpdate = { [weak self] locations in
            guard let newLocation = locations.last else { return }
            guard let annotation = self?.mapView.annotations.first else { return }
            let angle = .pi * (newLocation.course) / 180.0
            if let annotationView = self?.mapView.view(for: annotation), annotationView.reuseIdentifier == self?.annotationIdentifier {
                annotationView.transform =  CGAffineTransform.identity.rotated(by: CGFloat(angle))
            }
            self?.socket.send(message: "\(newLocation.description)")
        }

    }
}

private extension ViewController {
    func setupMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.standard
        mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) else {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.image = #imageLiteral(resourceName: "car")
            return view
        }
        dequeuedView.annotation = annotation
        dequeuedView.image = #imageLiteral(resourceName: "car")
        return dequeuedView
    }
}

