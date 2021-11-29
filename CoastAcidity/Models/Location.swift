//
//  Location.swift
//  CoastAcidity
//
//  Created by Stephen Tan on 11/28/21.
//

import Foundation
import MapKit

class Location: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(
        title: String?,
        coordinate: CLLocationCoordinate2D
    ) {
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return title
    }
}
