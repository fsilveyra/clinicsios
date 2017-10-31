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
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let loading = ActivityData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CreateGradienBackGround(view:self.view)
        self.navigationController?.navigationBar.isHidden = true
        loginBt.layer.cornerRadius = 4
        facebookBt.layer.cornerRadius = 4
        let attribRegBut : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue) : UIFont.systemFont(ofSize: 14),
            NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue) : UIColor.white,
            NSAttributedStringKey(rawValue: NSAttributedStringKey.underlineStyle.rawValue) : NSUnderlineStyle.styleSingle.rawValue]
        let attributeString = NSMutableAttributedString(string: "Register Here",
                                                        attributes: attribRegBut)
        registerHereBt.setAttributedTitle(attributeString, for: .normal)
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func faceBookLoginBtnAction(_ sender: Any) {
        //NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)
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
                                    //self.dict = result as! [String : AnyObject]
                                    print(result!)
                                    let json = JSON(result!)
                                    self.appDelegate.userName = json["name"].stringValue  //remove when image in server run
                                    self.appDelegate.userAvatarURL = json["picture"]["data"]["url"].stringValue //remove when image in server run


                                    ISClient.sharedInstance.registerWithFacebook(fb_social_token: FBSDKAccessToken.current().tokenString,fb_id: json["id"].stringValue).then { user -> Void in

                                            self.SwiftMessageAlert(layout: .CardView, theme: .success, title: "", body: "Register with Facebook success.")

                                            self.performSegue(withIdentifier: "loginSegue", sender: nil)

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
                //NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }
        }
    }
    
    


}
//Creating a diagonal Gradient
extension UIViewController{
    func CreateGradienBackGround(view: UIView!){
        let layer = CAGradientLayer()
        layer.frame = view.frame
        layer.colors = [UIColor.init(red: 24/255, green: 43/255, blue: 59/255, alpha: 1.0).cgColor, UIColor.init(red: 38/255, green: 142/255, blue: 133/255, alpha: 1).cgColor]
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

