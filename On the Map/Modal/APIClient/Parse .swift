//
//  Parse .swift
//  On the Map
//
//  Created by hind on 1/12/19.
//  Copyright © 2019 hind. All rights reserved.
//

import Foundation
class Parse {
    
    //MARK: Properties
    
    let sessionObject: Session
    
    //MARK: Singleton Class
    // MARK: Shared Instance
    
    private static var sharedManager = Parse()
    
    class func sharedInstance() -> Parse {
        return sharedManager
    }
    
    //MARK: Init Method
    
    init() {
        let apiUrlData = APIUrlData(scheme: APIComponents.scheme, host: APIComponents.host, path: APIComponents.path)
        sessionObject = Session(apiData: apiUrlData)
    }
    
    //MARK: Make Parse Client's Request
    
    private func makeRequestToParse(url: URL, method: HTTPMethod, body: [String : AnyObject]? = nil, responseClosure
        : @escaping (_ jsonAsDictionary: [String:AnyObject]?, _ error: String?) -> Void) {
        
        // Add Headers
        let requestHeaders = [
            RequestHeaderKeys.appId: RequestHeaderValues.appId,
            RequestHeaderKeys.APIKey: RequestHeaderValues.APIKey,
            RequestHeaderKeys.accept: RequestHeaderValues.application_json,
            RequestHeaderKeys.content_type: RequestHeaderValues.application_json
        ]
        
        //Make request
        sessionObject.makeRequest(Url: url, requestMethod: method, requestHeaders: requestHeaders, requestBody: body) { (data, error) in
            if let data = data{
                let jsonResponseDictionary = try! JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as!  [String : AnyObject]
                responseClosure(jsonResponseDictionary, nil)
            } else {
                responseClosure(nil, error)
            }
        }
        }
    
    
    //MARK: Get Multiple Student Locations
    
    func getMultipleStudentLocations(responseClosure: @escaping (_ studentLocations: [StudentLocationModel]?, _ error: String?) -> Void){
        
        // Build URL
        let url = sessionObject.urlForRequest(apiMethod: APIMethod.studentLocation, parameters: [
            ParameterKeys.limit: ParameterValues.hundred as AnyObject,
            ParameterKeys.order: ParameterValues.recentlyUpdated as AnyObject
            ])
        
        // Make Request
        makeRequestToParse(url: url, method: .GET){ (jsonResponseDic, error) in
            
            // Check for Errors
            guard error == nil else {
                responseClosure(nil, error)
                return
            }
            
            // Unwrap Response Json
            if let jsonResponseDic = jsonResponseDic, let studentLocationDics = jsonResponseDic[JSONResponseKeys.results] as? [[String : AnyObject]] {
                responseClosure(StudentLocationModel.locationsFromDictionaries(dictionaries: studentLocationDics), nil)
                return
            }
            
            responseClosure(nil, error)
        }
    }
    
    //MARK: Get Particular Student Location
    
    func getParticularStudentLocation(uniqueKey: String, responseClosure: @escaping (_ studentModel: StudentLocationModel?, _ error: String?) -> Void) {
        
        //Build URL
        let locationURL = sessionObject.urlForRequest(apiMethod: APIMethod.studentLocation, parameters: [ParameterKeys.Where: "{\"\(ParameterKeys.uniqueKey)\":\"" + "\(uniqueKey)" + "\"}" as AnyObject])
        
        //Make Request
        makeRequestToParse(url: locationURL, method: .GET) { (jsonResponseDic, error) in
            
            // Check for errors
            guard error == nil else {
                responseClosure(nil, error)
                return
            }
            
            // Unwrap Response Json
            if let jsonResponseDic = jsonResponseDic, let studentLocationDic = jsonResponseDic[JSONResponseKeys.results] as? [[String : AnyObject]] {
                
                if studentLocationDic.count == 1 {
                    
                    responseClosure(StudentLocationModel(dictionary: studentLocationDic[0]), nil)
                    return
                }
                
            }
            
            responseClosure(nil, error)
        }
    }
    
    //MARK: Post Students Location
    
    func postStudentsLocation(studentData: StudentLocationModel, mediaURL: String, responseClosure: @escaping (_ success: Bool, _ error: String?) -> Void){
        
        // Make URL
        let url = sessionObject.urlForRequest(apiMethod: APIMethod.studentLocation)
        
        // Set Json Body
        let requestBody: [String : AnyObject] = [StudentLocationKeys.uniqueKey: studentData.student.uniqueKey as AnyObject,
                                                 StudentLocationKeys.firstName: studentData.student.firstName as AnyObject,
                                                 StudentLocationKeys.lastName: studentData.student.lastName as AnyObject,
                                                 StudentLocationKeys.mapString: studentData.location.mapString as AnyObject,
                                                 StudentLocationKeys.mediaURL: mediaURL as AnyObject,
                                                 StudentLocationKeys.latitude: studentData.location.latitude as AnyObject,
                                                 StudentLocationKeys.longitude: studentData.location.longitude as AnyObject]
        
        makeRequestToParse(url: url, method: .POST, body: requestBody){ (jsonAsDictionary, error) in
            
            // Check for error
            guard error == nil else {
                responseClosure(false, error)
                return
            }
            
            // Handle known error
            if let jsonResponseDic = jsonAsDictionary, let error = jsonResponseDic[JSONResponseKeys.error] {
                responseClosure(false, error as? String)
                return
            }
            
            // Unwrap Json
            if let jsonResponseDic = jsonAsDictionary, let _ = jsonResponseDic[JSONResponseKeys.updatedAt] {
                responseClosure(true, nil)
                return
            }
            
            responseClosure(false, error)
        }
    }
    
    //MARK: Update Location
    
    func updateStudentLocationWith(mediaURL: String, studentData: StudentLocationModel, responseClosure: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        // Make URL
        let url = sessionObject.urlForRequest(apiMethod: APIMethod.studentLocation, pathExtension: "/\(studentData.objectID)")
        print(url)
        // Set Json Body
        let requestBody: [String : AnyObject] = [StudentLocationKeys.uniqueKey: studentData.student.uniqueKey as AnyObject,
                                                 StudentLocationKeys.firstName: studentData.student.firstName as AnyObject,
                                                 StudentLocationKeys.lastName: studentData.student.lastName as AnyObject,
                                                 StudentLocationKeys.mapString: studentData.location.mapString as AnyObject,
                                                 StudentLocationKeys.mediaURL: mediaURL as AnyObject,
                                                 StudentLocationKeys.latitude: studentData.location.latitude as AnyObject,
                                                 StudentLocationKeys.longitude: studentData.location.longitude as AnyObject]
        // Make request
        makeRequestToParse(url: url, method: .PUT, body: requestBody) { (jsonAsDictionary , error) in
            
            // Check for error
            guard error == nil else {
                responseClosure(false, error)
                return
            }
            
            // Handle known error
            if let jsonResponseDic = jsonAsDictionary, let error = jsonResponseDic[JSONResponseKeys.error] {
                print(jsonResponseDic)
                responseClosure(false, error as? String)
                return
            }
            
            if let jsonResponseDic = jsonAsDictionary, let _ = jsonResponseDic[JSONResponseKeys.updatedAt] {
                responseClosure(true, nil)
                return
            }
            
            responseClosure(false, error)
        }
    }
    
    
}
//MARK: Constants Extension
extension Parse {
    
    //MARK: API Components Constants
    
    struct APIComponents {
        static let scheme = "https"
        static let host = "parse.udacity.com"
        static let path = "/parse/classes"
    }
    
    //MARK: APIMrthods
    
    struct APIMethod {
        static let studentLocation = "/StudentLocation"
    }
    
    //MARK: HeaderKeys
    
    struct RequestHeaderKeys {
        static let appId = "X-Parse-Application-Id"
        static let APIKey = "X-Parse-REST-API-Key"
        static let accept = "Accept"
        static let content_type = "Content-Type"
    }
    
    //MARK: HeaderValues
    
    struct RequestHeaderValues {
        static let appId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let application_json = "application/json"
    }
    
    //MARK: Parameter Keys
    
    struct ParameterKeys {
        static let limit = "limit"
        static let order = "order"
        static let Where = "where"
        static let uniqueKey = "uniqueKey"
    }
    
    //MARK: Parameter Values
    
    struct ParameterValues {
        static let hundred = 100
        static let recentlyUpdated = "-updatedAt"
        static let recentlyCreated = "-createdAt"
    }
    
    //MARK: JSONResponseKeys
    
    struct JSONResponseKeys {
        static let error = "error"
        static let results = "results"
        static let objectID = "objectId"
        static let updatedAt = "updatedAt"
        static let uniqueKey = "uniqueKey"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let mapString = "mapString"
    }
    
    //MARK: Student Location Keys
    
    struct StudentLocationKeys {
        static let uniqueKey = "uniqueKey"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let mapString = "mapString"
    }
    
}
