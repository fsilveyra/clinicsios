//
//  LeftMenuVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 03/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire
import AlamofireImage

class LeftMenuVC: UIViewController {
    @IBOutlet weak var avatarIm:UIImageView!
    @IBOutlet weak var userName:UILabel!
    @IBOutlet weak var viewProfile:UIView!
    @IBOutlet weak var seeProfileBt:UIButton!
    @IBOutlet weak var logoutBt:UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        avatarIm.layer.cornerRadius = avatarIm.frame.width/2
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.SeeProfile))
        self.viewProfile.addGestureRecognizer(tapGesture)
        //self.userName.addGestureRecognizer(tapGesture)
        seeProfileBt.addTarget(self, action: #selector(SeeProfile), for: .touchUpInside)
        if !appDelegate.loggued{
            seeProfileBt.isHidden = true
            logoutBt.isHidden = true
        }
        else{
            seeProfileBt.isHidden = false
            logoutBt.isHidden = false
            avatarIm.image = #imageLiteral(resourceName: "Photo") //avatarIm.af_setImage(withURL: URL.init(string: appDelegate.userAvatarURL)!)
            userName.text = appDelegate.userName
        }
        // Do any additional setup after loading the view.
    }
    func SeeProfile(sender: UITapGestureRecognizer) {
        print("See Profile")
        if appDelegate.loggued {
            self.performSegue(withIdentifier: "goProfile", sender: nil)
        }
        else{
            self.performSegue(withIdentifier: "goLogin", sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Navigation
    @IBAction func Loggout(_ sender: AnyObject){
        self.appDelegate.loggued = false
        //send ISClient.Logout
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ShowwHome(_ sender: AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ShowFavorites(_ sender: AnyObject){
        print("See Favorites")
        if appDelegate.loggued {
            self.performSegue(withIdentifier: "goFavorites", sender: nil)
        }
        else{
            self.performSegue(withIdentifier: "goLogin", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
