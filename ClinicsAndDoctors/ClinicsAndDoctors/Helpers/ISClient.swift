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
        let alert = MessageView.viewFromNib(layout: .CardView)
        alert.configureTheme(.error)
        alert.configureContent(title: "Clinics&Doctors", body: self.description)
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
    var specialtysList = [Speciality]()
    var clinicsList = [Clinic]()
    var doctorsList = [Doctor]()

    private var reachabilityManager : Alamofire.NetworkReachabilityManager
    
    override init() {
        self.reachabilityManager = Alamofire.NetworkReachabilityManager(host: baseURL)!
        self.reachabilityManager.startListening()
        super.init()
    }
    
    // MARK: - Encoders and Decoders Image
    func encodeImageToBase64String(image:UIImage)->String{
        let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
        let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
        return strBase64
    }
    
    func decodeImageFromBase64String(strBase64:String)->UIImage{
        let dataDecoded:NSData = NSData(base64Encoded: strBase64, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
        return decodedimage
    }
    
    
    
    // MARK: Alamofire Request
    func request(endPoint: String, Params: Parameters, method: HTTPMethod? = .get, encoding: ParameterEncoding? = JSONEncoding.prettyPrinted , completion: @escaping ((_ data: JSON) -> Void)) {

        let headers = ["Content-Type" : "application/json"]
        // if let token = appDelegate.token{}
        //headers["access_token"] = appDelegate.token
        print(self.baseURL+endPoint)
        let c = Alamofire.request(self.baseURL + endPoint, method: method!, parameters: Params, encoding: encoding!, headers: headers)
            .responseJSON() { response in
                print("Alamofire Response \(response)")
                switch response.result {
                case .success(let json):
                    print(JSON(json))
                    completion(JSON(json))
                case .failure:
                    let status = ["code": "time_out",
                                  "detail": "Secure connection to the server cannot be made."]
                    let Json = JSON(status)
                    completion(Json)
                    print("error en la peticion")
                    //if let err = error as? AFError {
                        /*if err.isResponseSerializationError {
                        } else {
                        }*/
                    //}
                    print("error: \(response.error?.localizedDescription)")
                }
        }
        print(c.debugDescription)
    }



    // MARK: Authentication

    func login(phone:String, password:String) -> Promise<User> {
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
                            User.currentUser = User(representationJSON: js)
                            fulfill(User.currentUser!)
                        }else{
                            reject(LPError(code: "error", description: "Wrong mobile or password"))
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred"))
                    }
            }
        }
    }

    func registerWhitEmail(fullName:String, phone_number: String, email:String, password:String, picture:UIImage) -> Promise<User> {

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
                            User.currentUser = User(representationJSON: js)
                            fulfill(User.currentUser!)
                        }else{
                            reject(LPError(code: "error", description: "Register error. Please tray again with another credentials."))
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred"))
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
                            reject(LPError(code: "error", description: "Network error ocurred"))
                        }else{
                            if js["code"].stringValue == "RECOVERY_SUCCESS" {
                                fulfill()
                            }else{
                                reject(LPError(code: "error", description: "The specified user does not exist."))
                            }
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred"))
                    }
            }
        }
    }


    func registerWithFacebook(fb_social_token:String, fb_id:String) -> Promise<User> {

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
                            reject(LPError(code: "error", description: "Network error ocurred"))
                        }else{
                            if js["code"].stringValue == "REGISTER_WITH_FB_SUCCESSFUL" {
                                User.currentUser = User(representationJSON: js)
                                fulfill(User.currentUser!)
                            }else{
                                reject(LPError(code: "error", description: "Register error. Please tray again."))
                            }
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred"))
                    }
            }
        }
    }


    // MARK: GetData

    func getSpecialtys() -> Promise<[Speciality]> {
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
                            reject(LPError(code: "error", description: "Network error ocurred"))
                        }else{

                            if js["code"].stringValue == "GET_SPECIALTIES_UNSUCCESSFUL" {
                                reject(LPError(code: "error", description: "No specialties found."))
                            }
                            else{
                                var list = [Speciality]()
                                for item in js.arrayValue {
                                    list.append(Speciality(representationJSON: item))
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

    func getClinics(latitude: Double, longitude: Double, radius: Int, specialty_id:String?) -> Promise<[Clinic]> {
        let headers = ["Content-Type" : "application/json"]

        guard let user = User.currentUser else {
            return Promise { fulfill, reject in
                reject(LPError(code: "error", description: "Must be logged"))
            }
        }


        var parameters : Parameters = [
            "access_token": user.access_token,
            "latitude": latitude,
            "longitude": longitude,
            "radius": radius,
            "user_id":user.id
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
                            reject(LPError(code: "error", description: "Network error ocurred"))
                        }else{

                            if js["code"].stringValue == "GET_CLINICS_UNSUCCESSFUL" {
                                reject(LPError(code: "error", description: "Server error ocurred."))
                            }
                            else{
                                var list = [Clinic]()
                                for item in js.arrayValue {
                                    list.append(Clinic(representationJSON: item))
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

    //Get Doctors for specific clinic or/ands speciality
    func getDoctors(latitude: Double, longitude: Double, radius: Int, specialty_id:String?, clinic_id:String?, page:String?) -> Promise<[Doctor]> {

        let headers = ["Content-Type" : "application/json"]

        guard let user = User.currentUser else {
            return Promise { fulfill, reject in
                reject(LPError(code: "error", description: "Must be logged"))
            }
        }

        var parameters : Parameters = [
            "access_token": user.access_token,
            "latitude": latitude,
            "longitude": longitude,
            "radius": radius,
            "user_id":user.id
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
                            reject(LPError(code: "error", description: "Network error ocurred"))
                        }else{

                            if js["code"].stringValue == "GET_CLINICS_UNSUCCESSFUL" {
                                reject(LPError(code: "error", description: "Server error ocurred."))
                            }
                            else{
                                var list = [Doctor]()
                                for item in js.arrayValue {
                                    list.append(Doctor(representationJSON: item))
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

        guard let user = User.currentUser else {
            return Promise { fulfill, reject in
                reject(LPError(code: "error", description: "Must be logged"))
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
                            reject(LPError(code: "error", description: "Network error ocurred"))
                        }else{
                            if js["code"].stringValue == "ADD_FAVORITE_UNSUCCESSFUL" {
                                reject(LPError(code: "error", description: "Server error ocurred."))
                            }
                            else{
                                fulfill(true)
                            }
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred"))
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

        guard let user = User.currentUser else {
            return Promise { fulfill, reject in
                reject(LPError(code: "error", description: "Must be logged"))
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
                            reject(LPError(code: "error", description: "Network error ocurred"))
                        }else{
                            if js["code"].stringValue == "REMOVE_FAVORITE_UNSUCCESSFUL" {
                                reject(LPError(code: "error", description: "Server error ocurred."))
                            }
                            else{
                                fulfill(true)
                            }
                        }

                    case .failure(_):
                        reject(LPError(code: "error", description: "Network error ocurred"))
                    }
            }
        }

    }
}

