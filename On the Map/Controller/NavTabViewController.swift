//
//  NavTabViewController.swift
//  On the Map
//
//  Created by hind on 1/15/19.
//  Copyright © 2019 hind. All rights reserved.
//

import UIKit

class NavTabViewController: UINavigationController {

    let udacity = Udacity.sharedInstance()
    let datasource = StudentsDatasource.sharedDataSource()
    let parse = Parse.sharedInstance()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @objc func refershAction()
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"Student Locations Pinned Down"), object: nil);
    }
    @objc func logoutAction ()
     {
        udacity.logout(){ (success, error) in
            if success == true {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async{
                    self.alertWithError( error: "Logout Error")
                } }
            
        }
    }
    @objc func addlocationAction ()
    {
        //1-get Student Object
        if let currentStudent = datasource.student {
            //2- check if student has location before
            parse.getParticularStudentLocation(uniqueKey: currentStudent.uniqueKey) { (location, error) in
                
                DispatchQueue.main.async {
                    //3-A user has location before so we should get objectId so we can updated next
                    if let location = location {
                        self.overwriteAlert() { (alert)  in
                            self.datasource.objectId = location.objectID
                            self.segueforlocation()
                        }
                    } else {
                        //3-B user hasn't location before
                        self.segueforlocation()
                    } } } }
    }
    
    @IBAction func Logout(_ sender: Any) {
        logoutAction()
    }
    @IBAction func logOut(_ sender: Any) {
       logoutAction()
    }
    
    @IBAction func Addlocation(_ sender: Any) {
        
        addlocationAction()
    }
    @IBAction func addlocation(_ sender: Any) {
        addlocationAction()
    }
    
    @IBAction func refersh(_ sender: Any) {
        self.refershAction()
    }
    @IBAction func Refersh(_ sender: Any) {
         self.refershAction()
    }
    

    func alertWithError(error: String) {
        
        self.view.alpha = 1.0
        let alertView = UIAlertController(title: "", message: error, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title:"Dismiss", style:  .cancel, handler: nil))
        self.present(alertView, animated: true){
            self.view.alpha = 1.0
        }
    }
     private func segueforlocation (){
        let viewControlller = self.storyboard?.instantiateViewController(withIdentifier: "Addlocation")
        present(viewControlller!, animated: true, completion: nil)
    }
}
