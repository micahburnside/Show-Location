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
    var locationsArray: [CLLocation]? = []
    let mapView = MKMapView()
    var regionInMeters: Double = 250
    var currentLocation: CLLocation?
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupLocationManager()
        getDeviceLocation()
        centerViewOnUserLocation()

    }
    override func viewDidAppear(_ animated: Bool) {
//        takeLocationSnapShot()
    }
    
    func setupMapView() {
        mapView.delegate = self
        self.view = mapView
        self.mapView.showsCompass = true
        self.mapView.mapType = .hybrid
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
    
    func takeLocationSnapShot() {
        let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { Timer in
            self.takeLocationSnapShot()
        }
        locationsArray?.append(currentLocation!)
        print(self.locationsArray)
        print(self.locationsArray?.count )
        if self.locationsArray?.count ?? 10 == 10 {
            timer.invalidate()
            print("locationsArray.count has reached 10 locations: \(String(describing: locationsArray))")
        }
    }
    
    func takeSnaphotAtInterval() {

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
//                self.mapView.setUserTrackingMode(.follow, animated:true)

        self.mapView.setUserTrackingMode(.followWithHeading, animated: true)
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


