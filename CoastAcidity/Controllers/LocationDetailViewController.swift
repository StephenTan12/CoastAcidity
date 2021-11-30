//
//  LocationDetailViewController.swift
//  CoastAcidity
//
//  Created by Stephen Tan on 11/29/21.
//

import UIKit

class LocationDetailViewController: UIViewController {
    var originLocation: Location!
    var oceanLocation: Location!
    var locationName: String!
    
    func loadNavigationBar() {
        title = "\(locationName!)"
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
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadNavigationBar()
        
        print(originLocation.coordinate.latitude)
        print(originLocation.coordinate.longitude)
    }
}
