//
//  Speciality.swift
//  ClinicsAndDoctors
//
//  Created by reinier on 20/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import SwiftyJSON

class SpecialityModel: NSObject {

    static var specialities = [SpecialityModel]()

    var id : String!
    var name : String!
    var icon: String!
    
    override init() {
    }
    
    required init(representationJSON:SwiftyJSON.JSON) {
        self.id = representationJSON["id"].stringValue
        self.name = representationJSON["name"].stringValue
        self.icon = representationJSON["icon"].stringValue
    }

    static func by(id:String) ->SpecialityModel? {
        return SpecialityModel.specialities.filter { (c) -> Bool in
            c.id == id
            }.first
    }

    static func by(name:String) ->SpecialityModel? {
        return SpecialityModel.specialities.filter { (c) -> Bool in
            c.name == name
            }.first
    }
}
