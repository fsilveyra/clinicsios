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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        avatarIm.layer.cornerRadius = avatarIm.frame.width/2
        if (FBSDKAccessToken.current() != nil) {
            avatarIm.af_setImage(withURL: URL.init(string: appDelegate.userAvatarURL)!)
            userName.text = appDelegate.userName
        }
        else{
            //load parameters from user Model
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Navigation
    @IBAction func Loggout(_ sender: AnyObject){
        self.appDelegate.loggout = false
        self.dismiss(animated: true, completion: {
            self.navigationController?.popToRootViewController(animated: true)
        })
    }
    
    @IBAction func ShowwHome(_ sender: AnyObject){
        self.dismiss(animated: true, completion: nil)
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
