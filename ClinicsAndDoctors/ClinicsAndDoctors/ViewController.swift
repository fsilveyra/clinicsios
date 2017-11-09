//
//  ViewController.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 28/09/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON
import NVActivityIndicatorView

class ViewController: UIViewController {
    @IBOutlet weak var loginBt:UIButton!
    @IBOutlet weak var facebookBt:UIButton!
    @IBOutlet weak var registerHereBt:UIButton!

    var futureVC = ""
    var futureClinicId:String?
    var futureDoctorId:String?

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let loading = ActivityData()

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()

        CreateGradienBackGround(view:self.view)


        let attribRegBut : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue) : UIFont.systemFont(ofSize: 14),
            NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue) : UIColor.white,
            NSAttributedStringKey(rawValue: NSAttributedStringKey.underlineStyle.rawValue) : NSUnderlineStyle.styleSingle.rawValue]
        let attributeString = NSMutableAttributedString(string: "Register Here",
                                                        attributes: attribRegBut)
        registerHereBt.setAttributedTitle(attributeString, for: .normal)

    }


    override func viewWillAppear(_ animated: Bool) {
         self.navigationController?.navigationBar.isHidden = true
    }


    @IBAction func faceBookLoginBtnAction(_ sender: Any) {

        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile","email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        if((FBSDKAccessToken.current()) != nil){
                            NVActivityIndicatorPresenter.sharedInstance.startAnimating(self.loading)
                            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.width(100).height(100), email"]).start(completionHandler: { (connection, result, error) -> Void in
                                if (error == nil){
                                    let json = JSON(result!)
                                    self.appDelegate.userName = json["name"].stringValue

                                    self.appDelegate.userAvatarURL = json["picture"]["data"]["url"].stringValue

                                    ISClient.sharedInstance.registerWithFacebook(fb_social_token: FBSDKAccessToken.current().tokenString,fb_id: json["id"].stringValue).then {[weak self] user -> Void in

                                            self?.fbRegisterSuccess()

                                        }.always {
                                            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                                        }.catch { error in
                                            if let e: LPError = error as? LPError {
                                                e.show()
                                            }
                                    }

                                }
                            })
                        }
                    }
                }
            }
            else{
                print(error?.localizedDescription as Any)

            }
        }
    }


    func fbRegisterSuccess(){
        self.SwiftMessageAlert(layout: .cardView, theme: .success, title: "", body: "Register with Facebook success.")

        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + 1, execute: {[weak self] in

                if let nav = self?.navigationController{
                    if let fvc = self?.futureVC, fvc.isEmpty == false {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: fvc)

                        if let vcRating = vc as? RatingVC {
                            vcRating.clinicId = self?.futureClinicId
                            vcRating.doctorId = self?.futureDoctorId
                        }

                        let c = nav.viewControllers.count
                        nav.viewControllers.insert(vc, at: c - 1)
                        self?.navigationController?.popToViewController(vc, animated: true)
                    }else{
                        nav.popViewController(animated: true)
                    }
                }

        })
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "toLoginWithEmail" {
            (segue.destination as! LoginWithEmailVC).futureVC = self.futureVC
            (segue.destination as! LoginWithEmailVC).futureClinicId = self.futureClinicId
            (segue.destination as! LoginWithEmailVC).futureDoctorId = self.futureDoctorId

        }else if segue.identifier == "toRegister" {
            (segue.destination as! RegisterVC).futureVC = self.futureVC
            (segue.destination as! RegisterVC).futureClinicId = self.futureClinicId
            (segue.destination as! RegisterVC).futureDoctorId = self.futureDoctorId

        }


    }


    @IBAction func goBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }


}

//Creating a diagonal Gradient
extension UIViewController{
    func CreateGradienBackGround(view: UIView!){
        let layer = CAGradientLayer()
        layer.frame = view.frame
        layer.colors = [UIColor(red: 24/255, green: 43/255, blue: 59/255, alpha: 1.0).cgColor, UIColor(red: 38/255, green: 142/255, blue: 133/255, alpha: 1).cgColor]
        //layer.locations = [1.0 , 0.1]
        layer.startPoint = CGPoint(x: 0.4, y: 0.1)
        layer.endPoint = CGPoint(x: 0.0, y: 1.0)
        view.layer.insertSublayer(layer, at: 0)
    }
}

extension CALayer {
    
    func shake(duration: TimeInterval = TimeInterval(0.5)) {
        let animationKey = "shake"
        removeAnimation(forKey: animationKey)
        
        let kAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        kAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        kAnimation.duration = duration
        
        var needOffset = frame.width * 0.15,
        values = [CGFloat]()
        let minOffset = needOffset * 0.1
        
        repeat {
            values.append(-needOffset)
            values.append(needOffset)
            needOffset *= 0.5
        } while needOffset > minOffset
        
        values.append(0)
        kAnimation.values = values
        add(kAnimation, forKey: animationKey)
    }
}

