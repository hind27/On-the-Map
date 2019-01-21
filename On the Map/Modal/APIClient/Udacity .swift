//
//  Udacity .swift
//  On the Map
//
//  Created by hind on 1/12/19.
//  Copyright © 2019 hind. All rights reserved.
//

import Foundation

class Udacity {
    
    //MARK: Properties
    let sessionObject: Session
    
    //MARK: Singleton Class
    private static var sharedManager = Udacity()
    class func sharedInstance() -> Udacity {
        return sharedManager
    }
    
    //MARK: Init Method
    
    init() {
        let apiUrlData =  APIUrlData(scheme: APIComponents.scheme, host: APIComponents.host, path: APIComponents.path)
        sessionObject = Session(apiData: apiUrlData)
    }
    
    //MARK: Make Udacity Client's Request
    
    private func makeRequestToUdacity(url: URL, method: HTTPMethod, headers: [String : String]? = nil, body: [String : AnyObject]? = nil, responseClosure
        : @escaping (_ jsonAsDictionary: [String : AnyObject]? , _ error: String?) -> Void) {
        
        // Mandatory Headers
        var finalHeaders = [APIHeaderKeys.accept: APIHeaderValues.application_json, APIHeaderKeys.contentType: APIHeaderValues.application_json]
        
        // Add Extra headers if passed
        if let headers = headers {
            for (key, value) in headers {
                finalHeaders[key] = value
            }
        }
        
                // Make the request through Session Manager
            sessionObject.makeRequest(Url: url, requestMethod: method, requestHeaders: finalHeaders, requestBody: body) { (data, error) in
                        
                        // Check weather the data returned is not nil
                if let data = data {
                            do {
                                var newData = data as Data
                                let range = Range(5..<newData.count)
                                newData = newData.subdata(in: range)
                                print(String(data: newData, encoding: .utf8)!)
                               let jsonResponse = try JSONSerialization.jsonObject(with: newData, options: [])
                         
                                responseClosure(jsonResponse as? [String : AnyObject ], nil)
                    }
                            catch {
                          responseClosure(nil, Errors.worngInfo)
                    }
                    
                } else {
                           responseClosure(nil, error)
            }
        }
    }
    
    //MARK: Login through Udacity's Username & Password
    
    func loginWithCredentials(username: String, password: String, facebookToken: String? = nil, responseClosure: @escaping (_ userKey: String?, _ error: String?) -> Void){
        
        // Set Login URL
        let loginURL = sessionObject.urlForRequest(apiMethod: APIMethods.session)
        
        // Set HTTP Body
        var loginBody = [String : Any]()
        
        
        loginBody[HTTPBodyKeys.udacity] = [HTTPBodyKeys.username: username, HTTPBodyKeys.password: password]
        
        // Make request
        makeRequestToUdacity(url: loginURL, method: .POST, body: loginBody as [String : AnyObject]?) {(jsonResponseDictionary, error) in
            
            // Check For Errors
            guard error == nil else {
                responseClosure(nil, error)
                return
            }
            
            // Check for known error case
            if let jsonResponseDictionary = jsonResponseDictionary, let _ = jsonResponseDictionary[JSONResponseKeys.status] as? Int, let error = jsonResponseDictionary[JSONResponseKeys.error] as? String {
                responseClosure(nil, error)
                return
            }
            
            // Unwrap the Json Dictionary
            if let jsonResponseDictionary = jsonResponseDictionary, let account = jsonResponseDictionary[JSONResponseKeys.account] as? [String : AnyObject], let key = account[JSONResponseKeys.key] as? String {
                responseClosure(key, nil)
                return
            }
            
            responseClosure(nil, Errors.loginError)
        }
    }
    
    //MARK: Facebook Login
    
    func loginWithFacebook(token: String, responseClosure: @escaping (_ userKey: String?, _ error: String?) -> Void) {
        
        loginWithCredentials(username: "", password:  "", facebookToken: token, responseClosure: responseClosure)
    }
    
    //MARK: Fetch Student Data through key
    
    func fetchStudentData(fromKey: String, responseClosure: @escaping (_ student: StudentModel?, _ error: String?) -> Void){
        
        // Set Students URL
        let studentURL = sessionObject.urlForRequest(apiMethod: APIMethods.users, pathExtension: "/\(fromKey)")
        
        // Make Request
        makeRequestToUdacity(url: studentURL, method:.GET) { (jsonResponseDic, error) in
            
            // Check for Errors
            guard error == nil else {
                responseClosure(nil, error)
                return
            }
            if let userInformation = jsonResponseDic
            {

            //Unwrap the Json Dictionary
           // if let jsonResponseDic = jsonResponseDic
            //{
               // let userInformation = jsonResponseDic[JSONResponseKeys.user] as? [String:AnyObject]
                 
                let firstName = userInformation[JSONResponseKeys.firstName] as? String
                let lastName = userInformation[JSONResponseKeys.lastName]   as? String
          
                responseClosure(StudentModel(uniqueKey: fromKey, firstName:firstName! , lastName: lastName! , mediaURL: ""), nil)
                return
                }
    
            responseClosure(nil, Errors.noUserData)
        }
    }
    
    //MARK: Logout from Udacity
    
    func logout(responseClosure: @escaping (_ success: Bool, _ error: String?) -> Void){
        
        // Set Logout URL
        let logoutURL = sessionObject.urlForRequest(apiMethod: APIMethods.session)
        
        // Check Cookies & Set Required Headers
        var xsrfCookie: HTTPCookie? = nil
        var logoutHeaders = [String : AnyObject]()
        
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == Cookies.XSRF_Token{
                xsrfCookie = cookie
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            logoutHeaders[APIHeaderKeys.XSRF_Token] = xsrfCookie.value as AnyObject?
        }
        
        makeRequestToUdacity(url: logoutURL, method: .DELETE) { (jsonResponseDic, error) in
            
            //Check for errors
            guard error == nil else {
                responseClosure(false, error)
                return
            }
            
            //Unwrap Json response
            if let jsonResponseDic = jsonResponseDic, let _ = jsonResponseDic[JSONResponseKeys.session] as? [String : AnyObject] {
                responseClosure(true, nil)
                return
            }
            
            responseClosure(false, Errors.logoutError)
        }
    }
}

//MARK: Constants Extension
extension Udacity {
    
    //MARK: API Components Constants
    
    struct APIComponents {
        // https://onthemap-api.udacity.com/
        static let scheme = "https"
        static let host = "onthemap-api.udacity.com"
        static let path = "/v1"
    }
    
    //MARK: API Methods
    
    struct APIMethods {
        static let session = "/session"
        static let users = "/users"
    }
    
    //MARK: API Header Keys
    
    struct APIHeaderKeys  {
        static let accept = "Accept"
        static let contentType = "Content-Type"
        static let XSRF_Token = "X-XSRF-TOKEN"
    }
    
    // MARK: API Header Values
    
    struct APIHeaderValues {
        static let application_json = "application/json"
    }
    
    //MARK: API Requeest Body Keys
    
    struct HTTPBodyKeys {
        static let udacity = "udacity"
        static let username = "username"
        static let password = "password"
    }
    
    //MARK: JSON Response Keys
    
    struct JSONResponseKeys {
        static let account = "account"
        static let key = "key"
        static let session = "session"
        static let user = "user"
        static let firstName = "first_name"
        static let lastName = "last_name"
        static let status = "status"
        static let error = "error"
    }
    
    // MARK: Cookies
    
    struct Cookies {
        static let XSRF_Token = "XSRF-TOKEN"
    }
    
    //MARK: Errors
    
    struct Errors {
        static let loginError = "User was Unable to Login. Please try again later."
        static let logoutError = "User was Unable to Logout. Please try again later."
        static let noUserData = "Not able to access user data."
        static let worngInfo = "wrong email or password."
    }
    
    //MARK: SignUp URL
    
    static let signUpURL = "https://www.udacity.com/account/auth#!/signup"
}
