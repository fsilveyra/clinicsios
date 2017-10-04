//
//  LeftMenuVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 03/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class LeftMenuVC: UIViewController {
    @IBOutlet weak var avatarIm:UIImageView!
    @IBOutlet weak var userName:UILabel!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        avatarIm.layer.cornerRadius = avatarIm.frame.width/2
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func Loggout(_ sender: AnyObject){
        self.appDelegate.loggout = false
        self.dismiss(animated: true, completion: {
            self.navigationController?.popToRootViewController(animated: true)
        })
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
