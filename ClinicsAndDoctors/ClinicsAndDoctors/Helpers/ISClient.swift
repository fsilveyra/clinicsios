//
//  ISClient.swift
//  ClinicsAndDoctors
//
//  Created by reinier on 14/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PromiseKit
import SwiftMessages


class LPError : Error {
    let description:String
    let code:String

    init(code:String, description:String) {
        self.description = description
        self.code = code
    }

    func show(){
        let alert = MessageView.viewFromNib(layout: .cardView)
        alert.configureTheme(.error)
        alert.configureContent(title: "ClinicsAndDoctors", body: self.description)
        alert.button?.isHidden = true
        alert.configureDropShadow()
        SwiftMessages.show(view: alert)
    }

}


class ISClient: NSObject {
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    static let sharedInstance = ISClient()
    //let listOfServices:[Service]?
    //Local
    private var baseURL = (UIApplication.shared.delegate as! AppDelegate).webUrl
    var specialtysList = [SpecialityModel]()
    var clinicsList = [ClinicModel]()
    var doctorsList = [DoctorModel]()

    private var reachabilityManager : Alamofire.NetworkReachabilityManager
    
    override init() {
        self.reachabilityManager = Alamofire.NetworkReachabilityManager(host: baseURL)!
        self.reachabilityManager.startListening()
        super.init()
    }
    
    // MARK: - Encoders and Decoders Image
    func encodeImageToBase64String(image:UIImage)->String{
        let imageData:NSData = UIImageJPEGRepresentation(image, 0.9)! as NSData
        let strBase64:String = "data:image/jpeg;base64," + imageData.base64EncodedString(options: .lineLength64Characters)
        return strBase64
    }


    // MARK: Authentication

    func login(phone:String, password:String) -> Promise<UserModel> {
        let headers = ["Content-Type" : "application/json"]
        let parameters : Parameters = [
            "phone_number": phone,
            "password": password
        ]

        let endPoint = "login"

        return Promise { fulfill, reject in
            Alamofire.request(self.baseURL + endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in
                    
                    switch response.result {
                    case .success(let json):
                        let js = JSON(json)
                        if js != JSON.null && js["code"].stringValue == "LOGIN_SUCCESSFUL" {
                            UserModel.currentUser = UserModel(representationJSON: js)
                            UserModel.currentUser?.password = password
                            UserModel.saveSession()

                            fulfill(UserModel.currentUser!)
                        }else{
                            reject(LPError(code: "error", description: "Wrong mobile or password".localized))
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred".localized))
                    }
            }
        }
    }

    func registerWhitEmail(fullName:String, phone_number: String, email:String, password:String, picture:UIImage) -> Promise<UserModel> {

        let headers = ["Content-Type" : "application/json"]
        let parameters : Parameters = [
            "full_name": fullName,
            "phone_number": phone_number,
            "email": email,
            "password": password,
            "picture" : self.encodeImageToBase64String(image: picture),
            "user_role":"user"
        ]

        let endPoint = "register"

        return Promise { fulfill, reject in
            Alamofire.request(self.baseURL + endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in

                    switch response.result {
                    case .success(let json):
                        let js = JSON(json)
                        if js != JSON.null && js["code"].stringValue == "REGISTER_SUCCESSFUL" {
                            UserModel.currentUser = UserModel(representationJSON: js)
                            UserModel.currentUser?.password = password
                            UserModel.saveSession()

                            fulfill(UserModel.currentUser!)
                        }else{
                            reject(LPError(code: "error", description: "Register error. Please tray again with another credentials".localized))
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred".localized))
                    }
            }
        }
    }


    func forgotPassword(phone_number:String) -> Promise<Void> {

        let headers = ["Content-Type" : "application/json"]
        let parameters : Parameters = [
            "phone_number": phone_number
        ]

        let endPoint = "forgot_password"

        return Promise { fulfill, reject in
            Alamofire.request(self.baseURL + endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in

                    switch response.result {
                    case .success(let json):
                        let js = JSON(json)
                        if js == JSON.null {
                            reject(LPError(code: "error", description: "Network error ocurred".localized))
                        }else{
                            if js["code"].stringValue == "RECOVERY_SUCCESS" {
                                fulfill(())
                            }else{
                                reject(LPError(code: "error", description: "The specified user does not exist".localized))
                            }
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred".localized))
                    }
            }
        }
    }


    func registerWithFacebook(fb_social_token:String, fb_id:String) -> Promise<UserModel> {

        let headers = ["Content-Type" : "application/json"]
        let parameters : Parameters = [
            "fb_social_token": fb_social_token,
            "fb_id":fb_id,
            "user_role":"user"
        ]

        let endPoint = "register_with_fb"

        return Promise { fulfill, reject in
            Alamofire.request(self.baseURL + endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in

                    switch response.result {
                    case .success(let json):
                        let js = JSON(json)
                        if js == JSON.null {
                            reject(LPError(code: "error", description: "Network error ocurred".localized))
                        }else{
                            if js["code"].stringValue == "LOGIN_SUCCESSFUL" {
                                UserModel.currentUser = UserModel(representationJSON: js)
                                UserModel.currentUser?.password = ""
                                UserModel.saveSession()

                                fulfill(UserModel.currentUser!)
                            }else{
                                reject(LPError(code: "error", description: "Register error. Please tray again".localized))
                            }
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred".localized))
                    }
            }
        }
    }


    // MARK: GetData

    func getSpecialtys() -> Promise<[SpecialityModel]> {
        let headers = ["Content-Type" : "application/json"]
        let parameters : Parameters = [:]

        let endPoint = "get_specialties"

        return Promise { fulfill, reject in
            Alamofire.request(self.baseURL + endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in

                    switch response.result {
                    case .success(let json):
                        let js = JSON(json)
                        if js == JSON.null {
                            reject(LPError(code: "error", description: "Network error ocurred".localized))
                        }else{


                            if js["code"].stringValue == "GET_SPECIALTIES_UNSUCCESSFUL" {
                                reject(LPError(code: "error", description: "No specialties found".localized))
                            }
                            else{
                                var list = [SpecialityModel]()
                                for item in js.arrayValue {
                                    list.append(SpecialityModel(representationJSON: item))
                                }
                                fulfill(list)
                            }
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred".localized))
                    }
            }
        }
    }

    func getClinics(latitude: Double, longitude: Double, radius: Int, specialty_id:String?) -> Promise<[ClinicModel]> {
        let headers = ["Content-Type" : "application/json"]
        /*
        guard let user = User.currentUser else {
            return Promise { fulfill, reject in
                reject(LPError(code: "error", description: "Must be logged"))
            }
        }*/

        let user = UserModel.currentUser

        let conv = radius //Double(radius) //* 0.000621

        var parameters : Parameters = [
            "latitude": latitude,
            "longitude": longitude,
            "radius": conv,
            "user_id":user != nil ? user!.id : "-1"
        ]
        if let esp = specialty_id, esp.isEmpty == false {
            parameters.updateValue(esp, forKey: "specialty_id")
        }


        let endPoint = "get_clinics"

        return Promise { fulfill, reject in
            Alamofire.request(self.baseURL + endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in

                    switch response.result {
                    case .success(let json):
                        let js = JSON(json)
                        if js == JSON.null {
                            reject(LPError(code: "error", description: "Network error ocurred".localized))
                        }else{

                            if js["code"].stringValue == "GET_CLINICS_UNSUCCESSFUL" {
                                reject(LPError(code: "error", description: "Server error ocurred".localized))
                            }
                            else{
                                print("Get CLinics \(js.arrayValue)")
                                var list = [ClinicModel]()
                                for item in js.arrayValue {
                                    list.append(ClinicModel(representationJSON: item))
                                }
                                fulfill(list)
                            }
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred".localized))
                    }
            }
        }
    }

    //Get Doctors for specific clinic or/ands speciality
    func getDoctors(specialty_id:String?, clinic_id:String?) -> Promise<[DoctorModel]> {

        let headers = ["Content-Type" : "application/json"]

        let user = UserModel.currentUser

        var parameters : Parameters = [
//            "latitude": latitude,
//            "longitude": longitude,
//            "radius": radius,
            "user_id": user != nil ? user!.id : "-1"
        ]
        if let esp = specialty_id, esp.isEmpty == false {
            parameters.updateValue(esp, forKey: "specialty_id")
        }
        if let cid = clinic_id, cid.isEmpty == false {
            parameters.updateValue(cid, forKey: "clinic_id")
        }

        let endPoint = "get_doctors"

        return Promise { fulfill, reject in
            Alamofire.request(self.baseURL + endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in

                    switch response.result {
                    case .success(let json):
                        let js = JSON(json)
                        if js == JSON.null {
                            reject(LPError(code: "error", description: "Network error ocurred".localized))
                        }else{

                            if js["code"].stringValue == "GET_CLINICS_UNSUCCESSFUL" {
                                reject(LPError(code: "error", description: "Server error ocurred.".localized))
                            }
                            else{
                                var list = [DoctorModel]()
                                for item in js.arrayValue {
                                    list.append(DoctorModel(representationJSON: item))
                                }
                                fulfill(list)
                            }
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred"))
                    }
            }
        }
    }

    func addFavorite(clinicOrDoctorId:String, objType:String) -> Promise<Bool>{
        let headers = ["Content-Type" : "application/json"]

        if objType != "clinic" && objType != "doctor" {
            fatalError("must be clinic or doctor")
        }

        guard let user = UserModel.currentUser else {
            return Promise { fulfill, reject in
                reject(LPError(code: "error", description: "Must be logged in".localized))
            }
        }

        var parameters : Parameters = [
            "user_id": user.id
        ]
        parameters.updateValue(clinicOrDoctorId, forKey: objType == "clinic" ? "clinic_id" : "doctor_id")

        let endPoint = "add_favorite"

        return Promise { fulfill, reject in
            Alamofire.request(self.baseURL + endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in

                    switch response.result {
                    case .success(let json):
                        let js = JSON(json)
                        if js == JSON.null {
                            reject(LPError(code: "error", description: "Network error ocurred".localized))
                        }else{
                            if js["code"].stringValue == "ADD_FAVORITE_UNSUCCESSFUL" {
//                                reject(LPError(code: "error", description: "Server error ocurred."))
                                fulfill(false)
                            }
                            else{
                                fulfill(true)
                            }
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred".localized))
                    }
            }
        }

    }

    
    //Remove Clinic or Doctor as Favorite for User
    func removeFavorite(clinicOrDoctorId:String, objType:String) -> Promise<Bool>{
        let headers = ["Content-Type" : "application/json"]

        if objType != "clinic" && objType != "doctor" {
            fatalError("must be clinic or doctor")
        }

        guard let user = UserModel.currentUser else {
            return Promise { fulfill, reject in
                reject(LPError(code: "error", description: "Must be logged in".localized))
            }
        }

        var parameters : Parameters = [
            "user_id": user.id
        ]
        parameters.updateValue(clinicOrDoctorId, forKey: objType == "clinic" ? "clinic_id" : "doctor_id")

        let endPoint = "remove_favorite"

        return Promise { fulfill, reject in
            Alamofire.request(self.baseURL + endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in

                    switch response.result {
                    case .success(let json):
                        let js = JSON(json)
                        if js == JSON.null {
                            reject(LPError(code: "error", description: "Network error ocurred".localized))
                        }else{
                            if js["code"].stringValue == "REMOVE_FAVORITE_UNSUCCESSFUL" {
                                reject(LPError(code: "error", description: "Server error ocurred.".localized))
                            }
                            else{
                                fulfill(true)
                            }
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred".localized))
                    }
            }
        }

    }


    func editProfile(user_id:String, fullName:String?, phone_number: String?, email:String?, password:String?, picture:UIImage?) -> Promise<UserModel> {

        let headers = ["Content-Type" : "application/json"]
        var parameters : Parameters = [
            "user_id":user_id
        ]

        if let fullName = fullName {parameters.updateValue(fullName, forKey:"full_name")}
        if let phone_number = phone_number {parameters.updateValue(phone_number, forKey:"phone_number")}
        if let email = email {parameters.updateValue(email, forKey:"email")}
        if let password = password {parameters.updateValue(password, forKey:"password")}
        if let picture = picture {parameters.updateValue(self.encodeImageToBase64String(image: picture), forKey:"picture")}


        let endPoint = "edit_profile"

        return Promise { fulfill, reject in
            Alamofire.request(self.baseURL + endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in

                    switch response.result {
                    case .success(let json):
                        let js = JSON(json)

                        if js != JSON.null {
                            if js["code"].stringValue == "EDIT_PROFILE_UNSUCCESSFUL" {
                                reject(LPError(code: "error", description: "Unsuccessful profile editing".localized))
                            }else{
                                UserModel.currentUser = UserModel(representationJSON: js)
                                UserModel.currentUser?.password = password ?? ""
                                UserModel.saveSession()

                                fulfill(UserModel.currentUser!)
                            }

                        }else{
                            reject(LPError(code: "error", description: "Server error ocurred".localized))
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred".localized))
                    }
            }
        }
    }


    func getTermsOrPrivacy(endPoint:String) -> Promise<String> {
        let headers = ["Content-Type" : "application/json"]
        let parameters : Parameters = [:]

        return Promise { fulfill, reject in
            Alamofire.request(self.baseURL + endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in

                    switch response.result {
                    case .success(let json):
                        let js = JSON(json)
                        if js != JSON.null {
                            let result = js["description"].stringValue
                            fulfill(result)
                        }else{
                            reject(LPError(code: "error", description: "Server error ocurred".localized))
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred".localized))
                    }
            }
        }
    }



    func sendRating(clinicOrDoctorId:String, objType:String, value:Float, reason:String, comment:String?) -> Promise<Bool>{
        let headers = ["Content-Type" : "application/json"]

        if objType != "clinic" && objType != "doctor" {
            fatalError("must be clinic or doctor")
        }

        guard let user = UserModel.currentUser else {
            return Promise { fulfill, reject in
                reject(LPError(code: "error", description: "Must be logged in".localized))
            }
        }

        var parameters : Parameters = [
            "user_id": user.id,
            "value":value,
            "reason":reason
        ]

        if let comment = comment {
            parameters.updateValue(comment, forKey: "comment")
        }

        parameters.updateValue(clinicOrDoctorId, forKey: objType == "clinic" ? "clinic_id" : "doctor_id")

        let endPoint = "send_rating"

        return Promise { fulfill, reject in
            Alamofire.request(self.baseURL + endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in

                    switch response.result {
                    case .success(let json):
                        let js = JSON(json)
                        if js == JSON.null {
                            reject(LPError(code: "error", description: "Network error ocurred".localized))
                        }else{

                            if js["code"].stringValue == "SEND_RATING_UNSUCCESSFUL" {

//                                if js["detail"].stringValue == "Already rated." {
//                                    reject(LPError(code: "error", description: "Already rated."))
//                                }else{
                                    reject(LPError(code: "error", description: "Server error ocurred."))
//                                }

                            }
                            else{
                                fulfill(true)
                            }
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred".localized))
                    }
            }
        }

    }



    func getReviews(clinicOrDoctorId:String, objType:String) -> Promise<[ReviewModel]> {
        let headers = ["Content-Type" : "application/json"]
        var parameters : Parameters = [:]

        if objType != "clinic" && objType != "doctor" {
            fatalError("must be clinic or doctor")
        }

        parameters.updateValue(clinicOrDoctorId, forKey: objType == "clinic" ? "clinic_id" : "doctor_id")

        let endPoint = "get_reviews"

        return Promise { fulfill, reject in
            Alamofire.request(self.baseURL + endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in

                    switch response.result {
                    case .success(let json):
                        let js = JSON(json)

                        if js != JSON.null {
                            if js["code"].stringValue == "GET_REVIEWS_UNSUCCESSFUL" {
                                reject(LPError(code: "error", description: "Server error ocurred".localized))
                            }else{
                                var list = [ReviewModel]()
                                for item in js.arrayValue {
                                    list.append(ReviewModel(representationJSON: item))
                                }
                                fulfill(list)
                            }

                        }else{
                            reject(LPError(code: "error", description: "Server error ocurred".localized))
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred".localized))
                    }
            }
        }
    }








    func search(keyword:String, clinicId:String? = nil) -> Promise<[SearchResultModel]> {
        let headers = ["Content-Type" : "application/json"]

        var user_id = "-1"
        if let user = UserModel.currentUser {
            user_id = user.id
        }



        var parameters : Parameters = ["keyword":keyword, "user_id":user_id]

        if let clinic = clinicId{
            parameters.updateValue(clinic, forKey: "clinic_id")
        }

        let endPoint = "search"

        return Promise { fulfill, reject in
            Alamofire.request(self.baseURL + endPoint, method: .post, parameters: parameters, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseJSON { response in

                    switch response.result {
                    case .success(let json):
                        let js = JSON(json)

                        if js != JSON.null {

                            var list = [SearchResultModel]()
                            for item in js.arrayValue {


                                let obj = SearchResultModel(representationJSON: item, clinicId:clinicId)

                                list.append(obj)
                            }
                            fulfill(list)

                        }else{
                            reject(LPError(code: "error", description: "Server error ocurred".localized))
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred".localized))
                    }
            }
        }
    }

}




class SearchResultModel: NSObject {

    var id : String!
    var objType: String!
    var clinicData: ClinicModel? = nil
    var doctorData: DoctorModel? = nil

    override init() {
    }

    required init(representationJSON:SwiftyJSON.JSON, clinicId:String?) {
        self.id = representationJSON["id"].stringValue

        if let clinic = clinicId {
            objType = "doctor"
            self.doctorData = DoctorModel(representationJSON:representationJSON)
            self.doctorData?.idClinic = clinic

        }else{

            let cid = representationJSON["clinic","id"].stringValue
            if cid.isEmpty{
                objType = "clinic"
                self.clinicData = ClinicModel(representationJSON:representationJSON)
            }else{
                objType = "doctor"
                self.doctorData = DoctorModel(representationJSON:representationJSON)
            }
        }
    }


}



extension JSON {
    mutating func merge(other: JSON) {
        if self.type == other.type {
            switch self.type {
            case .dictionary:
                for (key, _) in other {
                    self[key].merge(other: other[key])
                }
            case .array:
                self = JSON(self.arrayValue + other.arrayValue)
            default:
                self = other
            }
        } else {
            self = other
        }
    }

    func mergedd(other: JSON) -> JSON {
        var merged = self
        merged.merge(other: other)
        return merged
    }
}

