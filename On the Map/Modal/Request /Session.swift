//
//  Session.swift
//  On the Map
//
//  Created by hind on 1/12/19.
//  Copyright © 2019 hind. All rights reserved.
//

import Foundation
//Global
//MARK: HTTP Request Method Enum
enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

//MARK: APIUrlData
struct APIUrlData {
    let scheme: String
    let host: String
    let path: String
}

class Session {
    
    //MARK: Properties
    
    private let session: URLSession!
    private let apiUrlData: APIUrlData
    
    //MARK: Initializer
    
    init(apiData: APIUrlData) {
        
        // Get your Configuration Object
        let sessionConfiguration = URLSessionConfiguration.default
        
        // Set the Configuration on your session object
        session = URLSession(configuration: sessionConfiguration)
        apiUrlData = apiData
    }
    
    //MARK: Data Task Request
    
    func makeRequest(Url: URL, requestMethod: HTTPMethod, requestHeaders: [String:String]? = nil, requestBody: [String:AnyObject]? = nil, responseClosure: @escaping (NSData?, String?) -> Void){
        
 
        // Create request from passed URL
        var request = URLRequest(url: Url)
        request.httpMethod = requestMethod.rawValue
        
        // Add headers if present
        if let requestHeaders = requestHeaders {
            for (key, value) in requestHeaders {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Add body if present
        if let requestBody = requestBody {
            
            request.httpBody = try! JSONSerialization.data(withJSONObject: requestBody, options: JSONSerialization.WritingOptions())
        }
        
        // Create Task
        let task = session.dataTask(with: request) {(data, response, error) in
            
            // Check for errors
            if let error = error {
                responseClosure(nil, error.localizedDescription)
                return
            }
            
            // Check for successful response via status codes
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode < 200 && statusCode > 299 {
                print("status code returned other than 2xx")
                responseClosure(nil,"Unsuccessful Status Code Received")
            }
            
            responseClosure(data as NSData?, nil);
        }
        
        task.resume()
    }
    
    //MARK: Build URL for request
    
    func urlForRequest(apiMethod: String?, pathExtension: String? = nil, parameters: [String : AnyObject]? = nil) -> URL {
        var components = URLComponents()
        components.scheme = apiUrlData.scheme
        components.host = apiUrlData.host
        components.path = apiUrlData.path + (apiMethod ?? "") + (pathExtension ?? "")
        
        if let parameters = parameters {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems?.append(queryItem)
            }
        }
        return components.url!
    }
}
