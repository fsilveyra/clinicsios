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
import MapKit

class UserModel: NSObject {
    static var currentUser :UserModel?
    var full_name : String = ""
    var phone_number : String = ""
    var password : String = ""
    var profile_picture : String = ""
    var email : String = ""
    var id: String!
    var access_token: String = ""

    static var mylocation:CLLocation?
    static var radiusLocationMeters:Int = 100000

    override init() {
    }
    
    required init(representationJSON:SwiftyJSON.JSON) {
        self.id = representationJSON["id"].stringValue
        self.full_name = representationJSON["full_name"].stringValue
        self.phone_number = representationJSON["phone_number"].stringValue
        self.password = representationJSON["password"].stringValue
        self.profile_picture = representationJSON["picture"].stringValue
        self.email = representationJSON["email"].stringValue
        self.access_token = representationJSON["access_token"].stringValue
    }

    static func saveSession(){
        if let user = UserModel.currentUser {
            UserDefaults.standard.set("\(user.id!)", forKey: "sesion_user_id")
            UserDefaults.standard.set(user.full_name, forKey: "sesion_full_name")
            UserDefaults.standard.set(user.password, forKey: "sesion_password")
            UserDefaults.standard.synchronize()
        }
    }

    static func currentSessionPassword() -> String?{
        return UserDefaults.standard.string(forKey: "sesion_password")
    }

    static func currentSessionUserId() -> String?{
        return UserDefaults.standard.string(forKey: "sesion_user_id")
    }

    static func removeSessionData(){
        UserDefaults.standard.set(nil, forKey: "sesion_user_id")
        UserDefaults.standard.set(nil, forKey: "sesion_full_name")
        UserDefaults.standard.set(nil, forKey: "sesion_password")
        UserDefaults.standard.synchronize()
    }


}
