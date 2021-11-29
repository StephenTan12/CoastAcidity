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
        searchBar.barTintColor = .white
        searchBar.searchTextField.textColor = .black
        searchBar.keyboardType = .numberPad
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Manually Enter Zipcode Here"
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
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        setupSearchBar()
        determineCurrentLocation()
    }
    
    func setupSearchBar() {
        let toolbar = UIToolbar()
        let flexspace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneBtnTapped))
        
        toolbar.setItems([flexspace, doneBtn], animated: true)
        toolbar.sizeToFit()
        
        searchBar.inputAccessoryView = toolbar
    }
    
    @objc func doneBtnTapped() {
        view.endEditing(true)
        
        let zipcode = searchBar.text
        
        if let enteredText = zipcode {
            if validateZipcode(input: enteredText) {
                goToSearchedLocation(zipcode: enteredText)
                
            }
            else {
                // incorrect zipcode
            }
        }
        else {
            // empty
        }
    }
    
    func validateZipcode(input: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "^[0-9]{5}(-[0-9]{4})?$").evaluate(with: input.uppercased())
    }
    
    func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        locationManager.requestLocation()
        
    }
    
    func goToSearchedLocation(zipcode: String) {
        CLGeocoder().geocodeAddressString(zipcode) { [weak self] (placemarks, error) in
            if let error = error {
                // unable to get location
                print("Unable to get location: \(error)")
            }
            
            if let placemarks = placemarks {
                guard let location = placemarks.first?.location else {
                    print("invalid zipcode")
                    return
                }
                
                self?.mapView.centerToLocation(CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                print("coordinates: -> \(location.coordinate.latitude), \(location.coordinate.longitude)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let location = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        mapView.centerToLocation(location)
        
        let currentLocation = Location(title: "Current Location", coordinate: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude))
        mapView.addAnnotation(currentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // handle failure
    }

}
private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
