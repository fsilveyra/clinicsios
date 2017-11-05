//
//  Category.swift
//  ClinicsAndDoctors
//
//  Created by reinier on 14/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import SwiftyJSON
class CategoryModel: NSObject {
    var id: Int!
    var name : String!
    var icon : String!

    override init() {
    }
    
    required init(representationJSON:SwiftyJSON.JSON) {
        self.id = representationJSON["id"].intValue
        self.name = representationJSON["name"].stringValue
        self.icon = representationJSON["icon"].stringValue
    }
}
