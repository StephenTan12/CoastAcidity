import UIKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    var searchBar: UISearchBar!
    var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var locationName: String!
    var chosenOcean: Location!
    var currentLocation: Location!
    let oceanCoordinates = [Location(title: "Pacific Ocean", coordinate: CLLocationCoordinate2D(latitude: 35.7832, longitude: -124.5085)), Location(title: "Atlantic Ocean", coordinate: CLLocationCoordinate2D(latitude: 34.599413, longitude: -69))]
    
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
        mapView.isRotateEnabled = false
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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
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
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
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
                let place = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                self?.updateAnnotation(coordinates: place)
            }
        }
    }
    
    func getLocationDetails(coordinates: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(coordinates) { [weak self] (placemarks, error) in
            if let error = error {
                print("Unable to fetch placemark: \(error)")
            }
            
            if let placemarks = placemarks {
                guard let cityName = placemarks.first?.locality else {
                    print("placemark messed up")
                    return
                }
                
                self?.locationName = cityName
            }
        }
    }
    
    func updateAnnotation(coordinates: CLLocation) {
        mapView.removeAnnotations(mapView.annotations)
        
        getLocationDetails(coordinates: coordinates)
        currentLocation = Location(title: "Current Location", coordinate: CLLocationCoordinate2D(latitude: coordinates.coordinate.latitude, longitude: coordinates.coordinate.longitude))
        
        mapView.addAnnotation(currentLocation)
        
        let pacificOceanLocation = CLLocation(latitude: oceanCoordinates[0].coordinate.latitude, longitude: oceanCoordinates[0].coordinate.longitude)
        let atlanticOceanLocation = CLLocation(latitude: oceanCoordinates[1].coordinate.latitude, longitude: oceanCoordinates[1].coordinate.longitude)
        
        print(coordinates.distance(from: atlanticOceanLocation)/1000)
        if coordinates.distance(from: pacificOceanLocation) > coordinates.distance(from: atlanticOceanLocation) {
            chosenOcean = oceanCoordinates[1]
        }
        else {
            chosenOcean = oceanCoordinates[0]
        }
        
        mapView.addAnnotation(chosenOcean)
        mapView.fitAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showLocationAlert(ocean: (self?.chosenOcean.title)!)
        }
    }
    
    func showLocationAlert(ocean: String) {
        let alert = UIAlertController(title: "Updated Location", message: "Closest Ocean is the \(ocean)", preferredStyle: .alert)
        let moreAction = UIAlertAction(title: "More Detail", style: .default) { [weak self] alert in
            let vc = LocationDetailViewController()
            vc.originLocation = self?.currentLocation
            vc.oceanLocation = self?.chosenOcean
            vc.locationName = self?.locationName
            
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        alert.addAction(moreAction)
        present(alert, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let location = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        updateAnnotation(coordinates: location)
        manager.stopUpdatingLocation()
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
    
    func fitAll() {
        var zoomRect = MKMapRect.null;
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
        }
        
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }
}
