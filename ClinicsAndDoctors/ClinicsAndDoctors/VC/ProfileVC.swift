//
//  ProfileVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 04/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    @IBOutlet weak var avatarIm:UIImageView!
    @IBOutlet weak var nameTf:UITextField!
    @IBOutlet weak var mobileTf:UITextField!
    @IBOutlet weak var emailTf:UITextField!
    @IBOutlet weak var changePasswordBt:UIButton!



    override func viewDidLoad() {
        super.viewDidLoad()
        CreateGradienBackGround(view: self.view)
        self.navigationController?.navigationBar.isHidden = false
        avatarIm.layer.cornerRadius = avatarIm.frame.width/2
        let attribRegBut : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue) : UIFont.systemFont(ofSize: 15),
            NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue) : UIColor.white,
            NSAttributedStringKey(rawValue: NSAttributedStringKey.underlineStyle.rawValue) : NSUnderlineStyle.styleSingle.rawValue]
        let attributeString = NSMutableAttributedString(string: "Change Password",
                                                        attributes: attribRegBut)
        changePasswordBt.setAttributedTitle(attributeString, for: .normal)

        self.loadUserData()
    }
    
    @IBAction func BackView(_ sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func EditFields(_ sender: AnyObject){
        if !nameTf.isEnabled {
            nameTf.isEnabled = true
            mobileTf.isEnabled = true
            emailTf.isEnabled = true
            self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "ok-green-icon")
        }
        else{
            nameTf.isEnabled = false
            mobileTf.isEnabled = false
            emailTf.isEnabled = false
            self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "icon_edit")
        }
    }

    func loadUserData(){

        guard let user = User.currentUser else { return }

        self.nameTf.text = user.full_name



    }
}
