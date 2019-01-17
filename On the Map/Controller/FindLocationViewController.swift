//
//  FindLocationViewController.swift
//  On the Map
//
//  Created by hind on 1/15/19.
//  Copyright © 2019 hind. All rights reserved.
//

import UIKit

class FindLocationViewController: UIViewController {
    
    private let parse = Parse.sharedInstance()
    private let dataSource = StudentsDatasource.sharedDataSource()
    var objectId: String? = nil
    
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
        if (locationText.text?.isEmpty)! {
            alertWithError(error:"Location Not Found")
            return
        }
        // check for empty media url
        if websiteTextField.text!.isEmpty {
            alertWithError(error: "Location Not Found")
            return
        }
        else {
            performSegue(withIdentifier: "mapViewSegue", sender: self)
        }
        /*guard let locationString = locationText.text, !locationString.isEmpty  else {
            alertWithError(error:"Location Not Found")
       
        }
        guard let url = websiteTextField.text, !url.isEmpty else {
            alertWithError(error:"Location Not Found")
            
        }
        // check for empty media url
        if (!url.contains("https://")) {
            alertWithError(error:"Location Not Found")
            
        }
        else {
            performSegue(withIdentifier:"mapViewSegue", sender: self)
        }*/
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "mapViewSegue") {
            let vc = segue.destination as! LocationViewController
            vc.location = locationText.text
            vc.mediaURL = websiteTextField.text
            
        }
    }
    // MARK: Prepare for Segue

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
