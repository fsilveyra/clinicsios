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
    @IBOutlet weak var avatarIm:RoundedImageView!
    @IBOutlet weak var userName:UILabel!
    @IBOutlet weak var viewProfile:UIView!
    @IBOutlet weak var seeProfileBt:UIButton!
    @IBOutlet weak var logoutBt:UIButton!
    @IBOutlet weak var homeBtn: UIButton!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var termsBtn: UIButton!
    @IBOutlet weak var privacyBtn: UIButton!


    let appDelegate = UIApplication.shared.delegate as! AppDelegate


    func translateStaticInterface(){
        userName.text = "Login / Register"
        seeProfileBt.setTitle("See Profile".localized, for: .normal)
        logoutBt.setTitle("Logout".localized, for: .normal)
        homeBtn.setTitle("Home".localized, for: .normal)
        favBtn.setTitle("Favorites".localized, for: .normal)
        termsBtn.setTitle("Terms of Use".localized, for: .normal)
        privacyBtn.setTitle("Privacy Policy".localized, for: .normal)

        underlineBtn(logoutBt)
        underlineBtn(seeProfileBt)
        underlineLbl(userName)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        translateStaticInterface()
        self.navigationController?.navigationBar.isHidden = true
        avatarIm.layer.cornerRadius = avatarIm.frame.width/2

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.SeeProfile))

        self.viewProfile.addGestureRecognizer(tapGesture)

        seeProfileBt.addTarget(self, action: #selector(SeeProfile), for: .touchUpInside)

    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        updateWithUserData()
    }


    func updateWithUserData(){
        if let user = UserModel.currentUser {
            seeProfileBt.isHidden = false
            logoutBt.isHidden = false
            userName.text = UserModel.currentUser?.full_name ?? ""

            if let url = URL(string: user.profile_picture) {
                self.avatarIm.url = url
            }
        }else{
            seeProfileBt.isHidden = true
            logoutBt.isHidden = true
        }
    }

    @objc func SeeProfile(sender: UITapGestureRecognizer) {
        if UserModel.currentUser != nil {
            self.performSegue(withIdentifier: "goProfile", sender: nil)
        }
        else{
            pressentLogin()
        }
    }


    func underlineBtn(_ btn:UIButton){
        let attribRegBut : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue) : btn.currentTitleColor,
            NSAttributedStringKey(rawValue: NSAttributedStringKey.underlineStyle.rawValue) : NSUnderlineStyle.styleSingle.rawValue]
        let attributeString = NSMutableAttributedString(string: btn.title(for: .normal) ?? "",
                                                        attributes: attribRegBut)
        btn.setAttributedTitle(attributeString, for: .normal)
    }

    func underlineLbl(_ btn:UILabel){
        let attribRegBut : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue) : btn.textColor,
            NSAttributedStringKey(rawValue: NSAttributedStringKey.underlineStyle.rawValue) : NSUnderlineStyle.styleSingle.rawValue]
        let attributeString = NSMutableAttributedString(string: btn.text ?? "",
                                                        attributes: attribRegBut)
        btn.attributedText = attributeString
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Navigation
    @IBAction func Loggout(_ sender: AnyObject){

        FBSDKLoginManager().logOut()
        
        UserModel.currentUser = nil

        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ShowwHome(_ sender: AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ShowFavorites(_ sender: AnyObject){
        if UserModel.currentUser != nil {
            self.performSegue(withIdentifier: "goFavorites", sender: nil)
        }
        else{
            pressentLogin("FavoritesVC")
        }
    }

    func pressentLogin(_ futureVC:String = ""){
        self.SwiftMessageAlert(layout: .cardView, theme: .info, title: "ClinicsAndDoctors", body: "Must be logged in first".localized)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {[weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! ViewController
            vc.futureVC = futureVC

            self?.navigationController?.pushViewController(vc, animated: true)
        })
       
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "toTerms" {
            let vc:TermsPolicyVC = segue.destination as! TermsPolicyVC
            vc.isTerms = true
        }else if segue.identifier == "toPrivacy" {
            let vc:TermsPolicyVC = segue.destination as! TermsPolicyVC
            vc.isTerms = false
        }
    }

}
