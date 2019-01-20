//
//  LocationModel.swift
//  On the Map
//
//  Created by hind on 1/12/19.
//  Copyright © 2019 hind. All rights reserved.
//


import UIKit
import MapKit

struct LocationModel : Codable
  {
    
    let latitude: Double
    let longitude: Double
    let mapString: String
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}
