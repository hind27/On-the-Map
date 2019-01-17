//
//  StudentModel.swift
//  On the Map
//
//  Created by hind on 1/12/19.
//  Copyright © 2019 hind. All rights reserved.
//

import Foundation
struct StudentModel : Codable
{
    let uniqueKey: String
    let firstName: String
    let lastName: String
    var mediaURL: String
    
     
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    init(uniqueKey: String, firstName: String, lastName: String , mediaURL: String) {
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.mediaURL = mediaURL
    }
    /*init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? "John"
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName) ?? "Smith"
        self.mediaURL = try container.decodeIfPresent(String.self, forKey: .mediaURL) ?? "www.hh.com"
        self.uniqueKey = try container.decodeIfPresent(String.self, forKey: .uniqueKey) ?? "3903878747"
        
    }*/
    

}
