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
        let attribRegBut : [String: Any] = [
            NSFontAttributeName : UIFont.systemFont(ofSize: 14),
            NSForegroundColorAttributeName : UIColor.white,
            NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue]
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
                            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.width(100).height(100), email"]).start(completionHandler: { (connection, result, error) -> Void in
                                //NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                                if (error == nil){
                                    //self.dict = result as! [String : AnyObject]
                                    print(result!)
                                    
                                    let json = JSON(result!)
                                    self.appDelegate.userName = json["name"].stringValue
                                    self.appDelegate.userAvatarURL = json["picture"]["data"]["url"].stringValue
                                    print("Login in System")
                                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                                    //print(self.dict)
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

