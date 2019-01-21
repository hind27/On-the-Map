//
//  TabBarViewController.swift
//  On the Map
//
//  Created by hind on 1/16/19.
//  Copyright © 2019 hind. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    let udacity = Udacity.sharedInstance()
    let datasource = StudentsDatasource.sharedDataSource()
    let parse = Parse.sharedInstance()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        // Do stuff
    }
    @IBAction func Login(_ sender: Any) {
       logoutClicked()
    }
    
    
    @IBAction func refersh(_ sender: Any) {
        refresh()
    }
    
    
    @IBAction func AddLocation(_ sender: Any) {
        addLocation()
    }
    
    @IBAction func refershMap(_ sender: Any) {
        refresh()
    }
    @IBAction func logoutMap(_ sender: Any) {
        logoutClicked()
    }
    
    @IBAction func Addlocation(_ sender: Any) {
        logoutClicked()
        
        
    }
    @objc func refresh() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Student Locations Pinned Down"), object: nil);
    }
    
    @objc func logoutClicked() {
        
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
    
    @objc func addLocation() {
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
                    } } } } }
    
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
    
    func studentLocationsPinnedDownError() {
        alertWithError(error: "unableToUpdateLocations" , title: "")
    }
    
    
    
    private func FindLocation (){
        let viewControlller = self.storyboard?.instantiateViewController(withIdentifier:"Add")
        present(viewControlller!, animated: true, completion: nil)
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
