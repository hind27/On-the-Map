//
//  MapViewController.swift
//  On the Map
//
//  Created by hind on 1/10/19.
//  Copyright © 2019 hind. All rights reserved.
//
import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController , MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Properties
    let datasource = StudentsDatasource.sharedDataSource()
    override func viewDidLoad() {
        super.viewDidLoad()
        observe()
        datasource.GetStudentsLocations()
    }
    
    @objc func studentLocationsUpdated() {
        if datasource.studentLocations.isEmpty {
            alertWithError(error: "Unable to fetch student locations. Please try again after some time or check your internet conectivity.")
            return
        }
        var annotations = [MKPointAnnotation]() //make array
        for studentLocation in datasource.studentLocations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = studentLocation.location.coordinate
            annotation.title = studentLocation.student.fullName
            annotation.subtitle = studentLocation.student.mediaURL
            annotations.append(annotation)
        }
        DispatchQueue.main.async {
        self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
            self.view.alpha = 1.0
        }
    }
    
    func observe() {
        // Observe Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(studentLocationsUpdated), name: NSNotification.Name(rawValue: "Student Locations Pinned Down"), object: nil)
    }
    
    
    func alertWithError(error: String) {
        
        self.view.alpha = 1.0
        let alertView = UIAlertController(title: "", message: error, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title:"Dismiss", style:  .cancel, handler: nil))
        self.present(alertView, animated: true){
            self.view.alpha = 1.0
        }
    }
        
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            let reuseId = "pin"
            var dropPinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            
            if dropPinView == nil {
                dropPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                dropPinView!.canShowCallout = true
                dropPinView!.pinTintColor = UIColor.red
                dropPinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            else {
                dropPinView!.annotation = annotation
            }
            
            return dropPinView
        }
        
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if control == view.rightCalloutAccessoryView {
                if let mediaURL = NSURL(string: ((view.annotation?.subtitle)!)!) {
                    if UIApplication.shared.canOpenURL(mediaURL as URL) {
                        UIApplication.shared.open(mediaURL as URL)
                    } else {
                        alertWithError(error:"Cannot Open URL")
                    }
                }
            }
        }
    

}

