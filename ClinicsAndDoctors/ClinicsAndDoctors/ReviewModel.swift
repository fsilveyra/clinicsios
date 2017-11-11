//
//  ReviewModel.swift
//  ClinicsAndDoctors
//
//  Created by Osmely Fernandez on 11/11/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//


import UIKit
import SwiftyJSON

class ReviewModel: NSObject {

    var id : String!
    var created_date_time : String!
    var updated_date_time: String!
    var comment: String!
    var rating: Float!
    var user: UserModel!



    override init() {
    }

    required init(representationJSON:SwiftyJSON.JSON) {
        self.id = representationJSON["id"].stringValue
        self.created_date_time = representationJSON["created_date_time"].stringValue
        self.updated_date_time = representationJSON["updated_date_time"].stringValue
        self.comment = representationJSON["comment"].stringValue
        self.rating = representationJSON["rating"].floatValue
        self.user = UserModel(representationJSON: representationJSON["user"])
    }


}


/*

 “id” : 1,
 “created_date_time”: “10/20/2016 12:00:00”,
 ​​​​“updated_date_time”: “11/20/2016 12:00:00”,
 "comment" : “lorem impsum”,
 “rating”: 3,
 “user”: ​{
 ​​“id”: 34,
 ​​“full_name” : “John Doe”,
 ​​“phone_number”: “2421313”,
 ​​“email”: “johndoe@infinixsoft.com”,
 ​​“picture”: “http://www.example.com/profile.jpg”
 ​​}
 },

 */

