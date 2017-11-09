//
//  Doctor.swift
//  ClinicsAndDoctors
//
//  Created by reinier on 14/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import SwiftyJSON

class DoctorModel: NSObject {

    static var doctors = [DoctorModel]()

    var full_name : String!
    var phone_number : String!
    var profile_picture : String!
    var email : String!
    var nationality : String!
    var idSpecialty : String!
    var idClinic: String!
    var id: String!
    var rating: Double!
    
    override init() {
    }
    
    required init(representationJSON:SwiftyJSON.JSON) {
        self.full_name = representationJSON["full_name"].stringValue
        self.phone_number = representationJSON["phone_number"].stringValue
        self.profile_picture = representationJSON["profile_picture"].stringValue
        self.email = representationJSON["email"].stringValue
        self.nationality = representationJSON["nationality"].stringValue
        self.id = representationJSON["id"].stringValue
        self.idSpecialty = representationJSON["specialty","id"].stringValue
        self.idClinic = representationJSON["clinic","id"].stringValue
        self.rating = representationJSON["rating"].doubleValue
    }

    static func by(id:String) ->DoctorModel? {
        return DoctorModel.doctors.filter { (c) -> Bool in
            c.id == id
            }.first
    }


}
