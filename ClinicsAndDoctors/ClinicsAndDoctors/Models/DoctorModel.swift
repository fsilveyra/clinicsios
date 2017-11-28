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
    var is_favorite:Bool!
    var dtype:String!
    
    override init() {
    }
    
    required init(representationJSON:SwiftyJSON.JSON) {
        self.full_name = representationJSON["full_name"].stringValue
        self.phone_number = representationJSON["phone_number"].stringValue
        self.profile_picture = representationJSON["picture"].stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        self.email = representationJSON["email"].stringValue
        self.nationality = representationJSON["nationality"].stringValue
        self.id = representationJSON["id"].stringValue
        self.idSpecialty = representationJSON["specialty","id"].stringValue
        self.idClinic = representationJSON["clinic","id"].stringValue
        self.rating = representationJSON["rating"].doubleValue
        self.is_favorite = representationJSON["is_favorite"].boolValue
        self.dtype = representationJSON["type"].stringValue
    }

    static func by(id:String) ->DoctorModel? {
        return DoctorModel.doctors.filter { (c) -> Bool in
            c.id == id
            }.first
    }

    static func isRated(docId:String) ->Bool{
        if let user = UserModel.currentUser {
            return UserDefaults.standard.bool(forKey: "rate_doc_" + docId + "_" + user.id)
        }

        return false
    }

    static func setRated(docId:String){
        if let user = UserModel.currentUser {
            UserDefaults.standard.set(true, forKey: "rate_doc_" + docId + "_" + user.id)
            UserDefaults.standard.synchronize()
        }
    }


}
