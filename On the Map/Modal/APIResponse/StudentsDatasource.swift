//
//  StudentsDatasource.swift
//  On the Map
//
//  Created by hind on 1/13/19.
//  Copyright © 2019 hind. All rights reserved.
//

import Foundation
class StudentsDatasource {
    
    //MARK: Properties
    private let parse = Parse.sharedInstance()
    var studentLocations = [StudentLocationModel]()
    var student: StudentModel? = nil
    var objectId : String?
    
    //MARK: Singleton Instance
    private static let sharedInstance = StudentsDatasource()
    
    class func sharedDataSource() -> StudentsDatasource  {
        return sharedInstance
    }
    
    //MARK: Pin Down Students Locations
    
    func GetStudentsLocations() {
        parse.getMultipleStudentLocations(){ (studentLocationDics, error) in
            // Check for Error
            if let error = error {
                NotificationCenter.default.post(name: NSNotification.Name("Student Locations Pinned Down Error"), object: nil)
            } else {
                guard let studentLocationDics = studentLocationDics else {
                    return
                }
                self.studentLocations = studentLocationDics
                NotificationCenter.default.post(name: NSNotification.Name("Student Locations Pinned Down"), object: nil);
            }
        }
    }
}
