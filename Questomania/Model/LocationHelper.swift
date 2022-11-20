//
//  LocationHelper.swift
//  Questomania
//
//  Created by Ярослав Косарев on 20.11.2022.
//

import CoreLocation

protocol LocationHelperDelegate: AnyObject {
    func userAtDesiredLocation()
}

class LocationHelper: NSObject {
    let desiredLocation: CLLocation
    let locationManager = CLLocationManager()
    weak var delegate: LocationHelperDelegate?
    
    init(lat: Double, lon: Double) {
        desiredLocation = CLLocation(latitude: lat, longitude: lon)
        super.init()
    }

    func start() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    private func handleNewLocation() {
        if let location = locationManager.location {
            let distance = location.distance(from: desiredLocation)
            if distance < 30 {
                delegate?.userAtDesiredLocation()
            }
        }
    }
}

extension LocationHelper: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        handleNewLocation()
    }
}
