//
//  Doctor.swift
//  ClinicsAndDoctors
//
//  Created by reinier on 14/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import SwiftyJSON

class Doctor: NSObject {
    static let sharedInstance = Doctor()
    var full_name : String!
    var phone_number : String!
    var profile_picture : String!
    var email : String!
    var nationality : String!
    var specialty : String!
    var idClinic: Int!
    var id: Int!
    
    override init() {
    }
    
    required init(representationJSON:SwiftyJSON.JSON) {
        self.full_name = representationJSON["full_name"].stringValue
        self.phone_number = representationJSON["phone_number"].stringValue
        self.profile_picture = representationJSON["profile_picture"].stringValue
        self.email = representationJSON["email"].stringValue
        self.nationality = representationJSON["nationality"].stringValue
        self.specialty = representationJSON["specialty"].stringValue
        self.idClinic = representationJSON["idClinic"].intValue
        self.id = representationJSON["id"].intValue
    }
}
