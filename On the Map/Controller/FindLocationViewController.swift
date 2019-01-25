//
//  FindLocationViewController.swift
//  On the Map
//
//  Created by hind on 1/15/19.
//  Copyright © 2019 hind. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class FindLocationViewController: UIViewController {
    
    private let parse = Parse.sharedInstance()
    private let dataSource = StudentsDatasource.sharedDataSource()
    private var mark: CLPlacemark?
    
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationText.delegate = self
        websiteTextField.delegate = self
        // Do any additional setup after loading the view.
    }

   
    @IBAction func Findlocation(_ sender: Any) {
        // Check if location textfield is empty or not.
        if (locationText.text?.isEmpty)! && websiteTextField.text!.isEmpty {
            alertWithError(error:"Location Not Found")
            return
        }else{
             //Add the placemark on the location
            let locationstring = locationText.text
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(locationstring!) { (placemarkArr, error) in
                //Check for errors
                if let _ = error {
                    self.alertWithError(error: "Could not geocode the string.")
                } else if (placemarkArr?.isEmpty)! {
                    self.alertWithError(error: "No location found.")
                } else {
                    self.mark = placemarkArr?.first
                    self.segueTomap()
                }
            }}}
    
    private func segueTomap() {
        // Start location on map
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        if  let resultVC = storyboard.instantiateViewController(withIdentifier:"mapViewSegue") as? UINavigationController, let vc = resultVC.topViewController as? LocationViewController {
              vc.location = locationText.text
              vc.mark = mark
              vc.mediaURL = websiteTextField.text
               self.navigationController?.pushViewController(vc, animated: true)
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

    @IBAction func actionDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

extension FindLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
   
}
