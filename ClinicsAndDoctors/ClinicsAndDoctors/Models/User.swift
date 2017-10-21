//
//  User.swift
//  ClinicsAndDoctors
//
//  Created by reinier on 14/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: NSObject {
    static let sharedInstance = User()
    var full_name : String!
    var phone_number : String!
    var password : String!
    var profile_picture : String!
    var email : String!
    var id: Int!
    override init() {
    }
    
    required init(representationJSON:SwiftyJSON.JSON) {
        self.id = representationJSON["id"].intValue
        self.full_name = representationJSON["full_name"].stringValue
        self.phone_number = representationJSON["phone_number"].stringValue
        self.password = representationJSON["password"].stringValue
        self.profile_picture = representationJSON["profile_picture"].stringValue
        self.email = representationJSON["email"].stringValue
    }
    
    func SetData(representationJSON: SwiftyJSON.JSON) {
        self.id = representationJSON["id"].intValue
        self.full_name = representationJSON["full_name"].stringValue
        self.phone_number = representationJSON["phone_number"].stringValue
        self.password = representationJSON["password"].stringValue
        self.profile_picture = representationJSON["profile_picture"].stringValue
        self.email = representationJSON["email"].stringValue
    }
}
