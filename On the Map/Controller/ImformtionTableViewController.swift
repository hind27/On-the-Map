//
//  ImformtionTableViewController.swift
//  On the Map
//
//  Created by hind on 1/12/19.
//  Copyright © 2019 hind. All rights reserved.
//

import UIKit

class ImformtionTableViewController: UITableViewController  {
  
    private let dataSource = StudentsDatasource.sharedDataSource()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observe()
       dataSource.GetStudentsLocations()
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
       
        return dataSource.studentLocations.count
    }
   
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! StudentLocationCell
        let studentLocation = dataSource.studentLocations[indexPath.row]
        cell.configureStudentLocationCell(studentLocation: studentLocation)
        return cell
       
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentURL = dataSource.studentLocations[indexPath.row].student.mediaURL
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

   
}
