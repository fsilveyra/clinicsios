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
    static var currentUser :UserModel? {
        didSet{
            saveSession()
        }
    }
    var full_name : String = ""
    var phone_number : String = ""
    var password : String = ""
    var profile_picture : String = ""
    var email : String = ""
    var id: String!


    static var mylocation:CLLocation?
    static var radiusLocationMeters:Int = 50

    override init() {
    }
    
    required init(representationJSON:SwiftyJSON.JSON) {
        self.id = representationJSON["id"].stringValue
        self.full_name = representationJSON["full_name"].stringValue
        self.phone_number = representationJSON["phone_number"].stringValue
        self.password = representationJSON["password"].stringValue
        self.profile_picture = representationJSON["picture"].stringValue
        self.email = representationJSON["email"].stringValue
        //self.access_token = representationJSON["access_token"].stringValue
    }


    static func loadSession() -> UserModel? {
        if let dic = UserDefaults.standard.dictionary(forKey: "sesion_user"){
            let js = JSON(dic)
            return UserModel(representationJSON: js)
        }else{
            return nil
        }
    }

    static func saveSession(){
        if let user = UserModel.currentUser {

            var dic:Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
            dic["id"] = user.id as AnyObject
            dic["full_name"] = user.full_name as AnyObject
            dic["phone_number"] = user.phone_number as AnyObject
            dic["password"] = user.password as AnyObject
            dic["picture"] = user.profile_picture as AnyObject
            dic["email"] = user.email as AnyObject

            UserDefaults.standard.set(dic, forKey: "sesion_user")

        }else{
            UserDefaults.standard.set(nil, forKey: "sesion_user")
        }

        UserDefaults.standard.synchronize()
    }


}
