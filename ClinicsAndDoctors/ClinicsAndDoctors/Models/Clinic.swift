//
//  Clinic.swift
//  ClinicsAndDoctors
//
//  Created by reinier on 14/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import SwiftyJSON

class Clinic: NSObject {
    var full_name : String!
    var phone_number : String!
    var password : String!
    var profile_picture : String!
    var specialtys: [Speciality]!
    var email : String!
    var address : String!
    var city: String!
    var state: String!
    var country: String!
    //var zipcode: Int!
    var latitude : Double!
    var longitude : Double!
    var id: Int!
    var rating: Int!
    var isFavorite: Bool!
    
    override init() {
    }
    
    required init(representationJSON:SwiftyJSON.JSON) {
        self.full_name = representationJSON["full_name"].stringValue
        self.phone_number = representationJSON["phone_number"].stringValue
        self.password = representationJSON["password"].stringValue
        self.profile_picture = representationJSON["picture"].stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        //self.category = Category.init(representationJSON: representationJSON["category"])
        self.email = representationJSON["email"].stringValue
        self.address = representationJSON["address"].stringValue
        self.city = representationJSON["city"].string
        self.state = representationJSON["state"].string
        self.country = representationJSON["country"].string
        //self.zipcode = representationJSON["zipcode"].intValue
        self.latitude = representationJSON["latitude"].doubleValue
        self.longitude = representationJSON["longitude"].doubleValue
        self.id = representationJSON["id"].intValue
        self.rating = representationJSON["rating"].intValue
        self.isFavorite = representationJSON["is_favorite"].boolValue
        let specialtysJSON = representationJSON["specialties"].arrayValue
        for specialty in specialtysJSON {
            self.specialtys.append(Speciality.init(representationJSON: specialty))
        }
    }
}
