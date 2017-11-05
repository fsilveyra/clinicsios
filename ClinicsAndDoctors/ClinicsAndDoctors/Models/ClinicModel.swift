//
//  Clinic.swift
//  ClinicsAndDoctors
//
//  Created by reinier on 14/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import SwiftyJSON

class ClinicModel: NSObject {
    var full_name : String!
    var phone_number : String!
    var password : String!
    var profile_picture : String!
    var specialtys = [String]()
    var email : String!
    var address : String!
    var city: String!
    var state: String!
    var country: String!
    //var zipcode: Int!
    var latitude : Double!
    var longitude : Double!
    var id: String!
    var rating: Int!
    var isFavorite: Bool!



    override init() {
    }
    
    required init(representationJSON:SwiftyJSON.JSON) {
        self.full_name = representationJSON["full_name"].stringValue
        self.phone_number = representationJSON["phone_number"].stringValue
        self.password = representationJSON["password"].stringValue
        self.profile_picture = representationJSON["picture"].stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let string = self.profile_picture.replacingOccurrences(of: "http", with: "https")
        self.profile_picture = string
        print("image url: \(self.profile_picture)")
        //self.category = Category.init(representationJSON: representationJSON["category"])
        self.email = representationJSON["email"].stringValue
        self.address = representationJSON["address"].stringValue
        self.city = representationJSON["city"].string
        self.state = representationJSON["state"].string
        self.country = representationJSON["country"].string
        //self.zipcode = representationJSON["zipcode"].intValue
        self.latitude = representationJSON["latitude"].doubleValue
        self.longitude = representationJSON["longitude"].doubleValue
        self.id = representationJSON["id"].stringValue
        self.rating = representationJSON["rating"].intValue
        self.isFavorite = representationJSON["is_favorite"].boolValue
        let specialtysJSON = representationJSON["specialties"].arrayValue
        for specialty in specialtysJSON {
            self.specialtys.append(SpecialityModel(representationJSON: specialty).id)
        }
    }

    func getDoctorNumber() ->Int {
        return DoctorModel.doctors.filter { (d) -> Bool in
            d.idClinic == self.id
            }.count
    }


    static var clinics = [ClinicModel]()

    static func by(id:String) ->ClinicModel? {
        return ClinicModel.clinics.filter { (c) -> Bool in
            c.id == id
        }.first
    }

    static func allDoctorsInClinics() ->[DoctorModel] {
        var result = [DoctorModel]()
        for clinic in ClinicModel.clinics {
            for doctor in DoctorModel.doctors {
                if doctor.idClinic == clinic.id {
                    result.append(doctor)
                }
            }
        }
        return result
    }


}
