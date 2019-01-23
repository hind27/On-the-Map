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
import CoreLocation

class MapViewController: UIViewController , MKMapViewDelegate, CLLocationManagerDelegate  {
     //MARK: Properties
    let udacity = Udacity.sharedInstance()
    let datasource = StudentsDatasource.sharedDataSource()
    let parse = Parse.sharedInstance()
    
    
    @IBOutlet weak var mapView: MKMapView!
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        observe()
        datasource.GetStudentsLocations()
    }
    
    @IBAction func refersh(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Student Locations Pinned Down"), object: nil);
        //Parse.updateStudentLocationWith()
    }
    @IBAction func Logout(_ sender: Any) {
        udacity.logout(){ (success, error) in
            if success == true {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async{
                    self.alertWithError(error: error!, title: "Logout Error" )
                } } }
    
       }
    
    
    
    @IBAction func Addlocation(_ sender: Any) {
        //1-get Student Object
        if let currentStudent = datasource.student {
            //2- check if student has location before
            parse.getParticularStudentLocation(uniqueKey: currentStudent.uniqueKey) { (location, error) in
                
                DispatchQueue.main.async {
                    //3-A user has location before so we should get objectId so we can updated next
                    if let location = location {
                        self.overwriteAlert() { (alert)  in
                            self.datasource.objectId = location.objectID
                            self.FindLocation()
                        }
                    } else {
                        //3-B user hasn't location before
                        self.FindLocation()
                    } } } }
    }
    
    
    private func FindLocation (){
        let viewControlller = self.storyboard?.instantiateViewController(withIdentifier:"Add")
        present(viewControlller!, animated: true, completion: nil)
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

                if let mediaURL = URL(string: ((view.annotation?.subtitle)!)!){
                    if UIApplication.shared.canOpenURL(mediaURL) {
                        UIApplication.shared.open(mediaURL, options: [:], completionHandler: nil)
                    } else {
                        alertWithError(error:"Cannot Open URL")
                    }
                }
            }
        }
    
    private func alertWithError(error: String, title: String) {
        
        let alertView = UIAlertController(title: title, message: error, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: AlertActions.dismiss, style: .cancel, handler: nil))
        self.present(alertView, animated: true){
            self.view.alpha = 1.0
        }
    }
    private func overwriteAlert(completionClosure: @escaping (UIAlertAction) -> Void){
        let alertView = UIAlertController(title: Alert.overWriteAlert, message: Alert.overWriteMessage, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: AlertActions.cancel, style: .cancel, handler: nil))
        alertView.addAction(UIAlertAction(title: AlertActions.overWrite, style: .default, handler: completionClosure))
        self.present(alertView, animated: true, completion: nil)
    }
    struct Alert {
        static let LoginAlertTitle = "Login Error"
        static let LogoutAlertTitle = "Logout Error"
        static let overWriteAlert = "Overwrite Location?"
        static let overWriteMessage = "You've already posted a pin. Would you like to overwrite it?"
    }
    
    //MARK: Alert Actions
    
    struct AlertActions {
        static let dismiss = "Dismiss"
        static let overWrite = "Overwrite"
        static let cancel = "Cancel"
    }
}

