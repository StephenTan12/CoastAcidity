//
//  HomeViewController.swift
//  CoastAcidity
//
//  Created by Stephen Tan on 11/27/21.
//

import UIKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    var searchBar: UISearchBar!
    var mapView: MKMapView!
    var locationManager: CLLocationManager!
    
    func loadNavigationBar() {
        title = "home"
        navigationController?.navigationBar.isHidden = false
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .lightGray
        appearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 20.0), .foregroundColor: UIColor.black]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        
        searchBar = UISearchBar()
        searchBar.keyboardType = .numberPad
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Enter something here"
        view.addSubview(searchBar)
        
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            searchBar.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            searchBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 30),
            searchBar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -30),
            mapView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 30),
            mapView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let initialLocation = CLLocation(latitude: 32.888624, longitude: -117.241736)
//
//        mapView.centerToLocation(initialLocation)
        determineCurrentLocation()
    }
    
    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let location = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        mapView.centerToLocation(location)
    }

}
private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
