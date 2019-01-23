//
//  LocationViewController.swift
//  On the Map
//
//  Created by hind on 1/16/19.
//  Copyright © 2019 hind. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationViewController: UIViewController ,MKMapViewDelegate, CLLocationManagerDelegate  {
  
    enum UIState { case loading, unloading }
    //MARK: Properties
    private let parse = Parse.sharedInstance()
    private let dataSource = StudentsDatasource.sharedDataSource()
    var objectId: String? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var mark: CLPlacemark? = nil
    var location : String?
    var mediaURL : String?

    override func viewDidLoad() {
        super.viewDidLoad()

        //Add the placemark on the location
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location!) { (placemarkArr, error) in
            
            //Check for errors
            if let _ = error {
                self.alertWithError(error: "Could not geocode the string.")
            } else if (placemarkArr?.isEmpty)! {
                self.alertWithError(error: "No location found.")
            } else {
                self.setUIForState(.unloading)
                self.mark = placemarkArr?.first
                self.mapView?.showAnnotations([MKPlacemark(placemark: self.mark!)], animated: true)
            }
        }
    }

    @IBAction func submitClicked(_ sender: Any) {
        //1- create location Object
        
        let location = LocationModel(latitude: (mark?.location?.coordinate.latitude)!, longitude: (mark?.location?.coordinate.longitude)!, mapString: mediaURL!)

       
        //2-A if user has location before update with new one
        if let objectId = self.objectId {
            parse.updateStudentLocationWith(mediaURL: mediaURL!, studentData: StudentLocationModel(objectID: objectId, student: dataSource.student!, location: location)) { (success, error) in
                if let e = error {
                    self.alertWithError(error: e)
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Student Locations Pinned Down"), object: nil)
                    self.dataSource.student?.mediaURL = self.mediaURL!
                    self.dismiss(animated: true, completion: nil)
                   }
                }
           }
            //2-A if user hasn't location before post new one
        else {
            parse.postStudentsLocation(studentData: StudentLocationModel(student: dataSource.student!, location: location), mediaURL: mediaURL!) { (success, error) in
                if let _ = error {
                    self.alertWithError(error: "Student location could not be posted.")
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Student Locations Pinned Down"), object: nil);
                    self.dataSource.student?.mediaURL = self.mediaURL!
                    DispatchQueue.main.async(execute: {
                        //UI Related Function
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                }
            }
        }
    }

    func alertWithError(error: String) {
        self.view.alpha = 1.0
        let alertView = UIAlertController(title: "", message: error, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title:"Dismiss", style: .cancel, handler: nil))
        self.present(alertView, animated: true){
            self.view.alpha = 1.0
        }
    }
    
    func setUIForState(_ state: UIState) {
        switch state {
            
        case .loading:
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            submit?.isEnabled = false
            self.view.alpha = 0.5
            
        case .unloading :
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            submit?.isEnabled = true
            self.view.alpha = 1.0
        }}

}
