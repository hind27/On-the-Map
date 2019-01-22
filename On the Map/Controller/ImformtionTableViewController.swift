//
//  ImformtionTableViewController.swift
//  On the Map
//
//  Created by hind on 1/12/19.
//  Copyright © 2019 hind. All rights reserved.
//

import UIKit

class ImformtionTableViewController: UITableViewController  {
  
    let udacity = Udacity.sharedInstance()
    let datasource = StudentsDatasource.sharedDataSource()
    let parse = Parse.sharedInstance()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observe()
        datasource.GetStudentsLocations()
    }

    func observe() {
        // Observe Notifications
        // here to be able to get the new data
        NotificationCenter.default.addObserver(self, selector: #selector(studentLocationsUpdated), name: NSNotification.Name(rawValue:"Student Locations Pinned Down"), object: nil)
    }
    
    @objc func studentLocationsUpdated() {
        DispatchQueue.main.async {
             self.tableView.alpha = 1.0
            self.tableView.reloadData()
            
        }}
    
    func alertWithError(error: String) {
        let alertView = UIAlertController(title: "", message: error, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertView, animated: true){
            self.view.alpha = 1.0
        }
    }
    // MARK: - Table view data source
    
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return datasource.studentLocations.count
    }
   
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! StudentLocationCell
        let studentLocation = datasource.studentLocations[indexPath.row]
        cell.configureStudentLocationCell(studentLocation: studentLocation)
        return cell
       
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentURL = datasource.studentLocations[indexPath.row].student.mediaURL
        //guard let studentLocation = CurrentSessionData.shared.studentLocations?[indexPath.row], let mediaUrl = studentLocation.mediaURL, !mediaUrl.isEmpty else {
            //AlertHelper.showAlert(in: self, withTitle: "Error", message: ErrorMessage.couldNotOpenURL.rawValue)
        // Check if it exists & proceed accordingly
        if let studentMediaURL = URL(string: studentURL), UIApplication.shared.canOpenURL(studentMediaURL) {
            // Open URL
            UIApplication.shared.open(studentMediaURL)
        } else {
            // Return with Error
           alertWithError(error:"Cannot Open URL")
        }
    }

    @IBAction func logout(_ sender: Any) {
        udacity.logout(){ (success, error) in
            if success == true {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async{
                    self.alertWithError(error: error!, title:"Logout Error" )
                } } }
    }
    @IBAction func refersh(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Student Locations Pinned Down"), object: nil);
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
