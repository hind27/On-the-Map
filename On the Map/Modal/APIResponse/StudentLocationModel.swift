//
//  StudentLocationModel.swift
//  On the Map
//
//  Created by hind on 1/12/19.
//  Copyright © 2019 hind. All rights reserved.
//

import Foundation
struct StudentLocationModel  {
    
    //MARK: Properties
    
    let student: StudentModel
    let location: LocationModel
    let objectID: String
    
    
    init(dictionary: [String : AnyObject]) {
        objectID = dictionary[Parse.JSONResponseKeys.objectID] as? String ?? ""
        
        // Fill StudentModel Data
        let firstName = dictionary[Parse.JSONResponseKeys.firstName] as? String ?? ""
        let lastName = dictionary[Parse.JSONResponseKeys.lastName] as? String ?? ""
        let uniqueKey = dictionary[Parse.JSONResponseKeys.uniqueKey] as? String ?? ""
        let mediaURL = dictionary[Parse.JSONResponseKeys.mediaURL] as? String ?? ""
        student = StudentModel(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mediaURL: mediaURL)
        
        // Fill LocationModel Data
        let latitude = dictionary[Parse.JSONResponseKeys.latitude] as? Double ?? 0.0
        let longitude = dictionary[Parse.JSONResponseKeys.longitude] as? Double ?? 0.0
        let mapString = dictionary[Parse.JSONResponseKeys.mapString] as? String ?? ""
        location = LocationModel(latitude: latitude, longitude: longitude, mapString: mapString)
    }
    
    init(student: StudentModel, location: LocationModel) {
        objectID = ""
        self.student = student
        self.location = location
    }
    
    init(objectID: String, student: StudentModel, location: LocationModel) {
        self.objectID = objectID
        self.student = student
        self.location = location
    }
    
    //Helper Methods
    static func locationsFromDictionaries(dictionaries: [[String:AnyObject]]) -> [StudentLocationModel] {
        var studentLocations = [StudentLocationModel]()
        for studentDictionary in dictionaries {
            studentLocations.append(StudentLocationModel(dictionary: studentDictionary))
        }
        return studentLocations
    }
    
}
