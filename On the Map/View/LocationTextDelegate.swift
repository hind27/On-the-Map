//
//  LocationTextDelegate.swift
//  On the Map
//
//  Created by hind on 1/15/19.
//  Copyright © 2019 hind. All rights reserved.
//

import UIKit

class LocationTextDelegate: NSObject ,UITextFieldDelegate
{
   
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
