//
//  LoginViewController.swift
//  On the Map
//
//  Created by hind on 1/10/19.
//  Copyright © 2019 hind. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController{
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    enum UIState { case  Normal, Login }
    
    // MARK: Text Field Delegate Objects
    let locationTextDelegate = LocationTextDelegate()
    let udacity = Udacity.sharedInstance()
    let datasource = StudentsDatasource.sharedDataSource()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set UI State
        setUIForState(.Normal)
        userEmail.delegate = self
        userPassword.delegate = self
    }
    // MARK: Login
    @IBAction func Login(_ sender: Any) {
        if userEmail.text!.isEmpty || userPassword.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
            // Set UI State
            setUIForState(.Login)
            udacity.loginWithCredentials(username:userEmail.text!, password:userPassword.text!) { (userKey, error) in
                DispatchQueue.main.async {                    //Check for user key
                    if let userKey = userKey {
                        self.udacity.fetchStudentData(fromKey: userKey) { (student, error) in
                            DispatchQueue.main.async {
                                if let student = student {
                                    self.datasource.student = student
                                    self.completeLogin()
                                } else {
                                    self.alertWithError(error: error!)
                                }     }}
                    } else {
                        self.alertWithError(error: error!)
                    }
                }
            }
        }
    }
    
    
    private func completeLogin() {
        // Start Home Screen
        
        if let controller =  self.storyboard?.instantiateViewController(withIdentifier:"ShowMap") {
            present(controller, animated: true, completion: nil)
        }
    }
    @IBAction func signUpPressed(_ sender: Any) {
        guard let url = URL(string: "https://auth.udacity.com/sign-up") else { return }
        UIApplication.shared.open(url)
        
    }
    
    func setUIForState(_ state: UIState) {
        switch state {
        case .Normal:
            setEnabled(enabled: true)
            userEmail.text = ""
            userPassword.text = ""
            activityIndicator.stopAnimating()
        case .Login:
            setEnabled(enabled: false)
            activityIndicator.startAnimating()
            debugTextLabel.text = ""
            
        }
    }
    
    private func setEnabled(enabled: Bool){
        activityIndicator.isHidden = enabled
        loginButton.isEnabled = enabled
        userEmail.isEnabled = enabled
        userPassword.isEnabled = enabled
    }
    
    
    private func alertWithError(error: String) {
        
        let alertView = UIAlertController(title:"Login Error", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title:"Dismiss", style: .cancel) {
            UIAlertAction in
            self.setUIForState(.Normal)
        }
        alertView.addAction(cancelAction)
        self.present(alertView, animated: true){
        }
        
    }
}


extension LoginViewController: UITextFieldDelegate {
    
    // MARK: Show/Hide Keyboard
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= getKeyboardHeight(notification)
            iconImageView.isHidden = true
        }
    }
    
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    @objc func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

private extension LoginViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}


