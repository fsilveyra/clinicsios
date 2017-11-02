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
        if User.currentUser == nil {
            seeProfileBt.isHidden = true
            logoutBt.isHidden = true
        }
        else{
            seeProfileBt.isHidden = false
            logoutBt.isHidden = false
            avatarIm.image = #imageLiteral(resourceName: "Photo") //avatarIm.af_setImage(withURL: URL.init(string: appDelegate.userAvatarURL)!)
            userName.text = User.currentUser?.full_name ?? ""
        }
        // Do any additional setup after loading the view.
    }
    @objc func SeeProfile(sender: UITapGestureRecognizer) {
        print("See Profile")
        if User.currentUser != nil {
            self.performSegue(withIdentifier: "goProfile", sender: nil)
        }
        else{
            pressentLogin()
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
        User.currentUser = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ShowwHome(_ sender: AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ShowFavorites(_ sender: AnyObject){
        if User.currentUser != nil {
            self.performSegue(withIdentifier: "goFavorites", sender: nil)
        }
        else{
            pressentLogin()
        }
    }

    func pressentLogin(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! ViewController
        vc.futureVC = "FavoritesVC"
        navigationController?.pushViewController(vc, animated: true)
    }


}
