//
//  ViewController.swift
//  Show-Location
//
//  Created by Micah Burnside on 4/10/22.
//

import UIKit
import MapKit
import CoreLocation

class LocationViewController: UIViewController, MKMapViewDelegate {

    let mapView = MKMapView()
    var regionInMeters: Double = 250
    private var currentLocation: CLLocation?
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view = mapView
        setupLocationManager()
        getDeviceLocation()
        centerViewOnUserLocation()
    }
    override func viewDidAppear(_ animated: Bool) {
        print(currentLocation?.coordinate.latitude)
        print(currentLocation?.coordinate.longitude)
    }
    func getDeviceLocation() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    /// locationManagerDidChangeAuthorization
    /// - Parameter manager: locationManager
    /// The system calls this method when the app creates the related object’s CLLocationManager instance, and when the app’s authorization status changes. The status informs the app whether it can access the user’s location. Core Location always calls locationManagerDidChangeAuthorization(_:) when the user’s action results in an authorization status change, and when your app creates an instance of CLLocationManager, whether your app runs in the foreground or in the background.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.requestLocation()
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("error getting user location, error: \(error.localizedDescription)")
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationViewController: CLLocationManagerDelegate {
    func locationManager(
      _ manager: CLLocationManager,
      didChangeAuthorization status: CLAuthorizationStatus
    ) {
      // 1
      guard status == .authorizedWhenInUse else {
        return
      }
      manager.requestLocation()
    }

    func locationManager(
      _ manager: CLLocationManager,
      didUpdateLocations locations: [CLLocation]
    ) {
        defer { currentLocation = locations.last }

        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
//                let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
                let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
                mapView.setRegion(region, animated: true)
            }
        }
    }

}


