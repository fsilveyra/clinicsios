//
//  User.swift
//  ClinicsAndDoctors
//
//  Created by reinier on 14/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import SwiftyJSON
import PromiseKit

class User: NSObject {
    static var currentUser :User?
    var full_name : String = ""
    var phone_number : String = ""
    var password : String = ""
    var profile_picture : String = ""
    var email : String = ""
    var id: Int!
    var access_token: String = ""

    override init() {
    }
    
    required init(representationJSON:SwiftyJSON.JSON) {
        self.id = representationJSON["id"].intValue
        self.full_name = representationJSON["full_name"].stringValue
        self.phone_number = representationJSON["phone_number"].stringValue
        self.password = representationJSON["password"].stringValue
        self.profile_picture = representationJSON["profile_picture"].stringValue
        self.email = representationJSON["email"].stringValue
        self.access_token = representationJSON["access_token"].stringValue
    }


}
