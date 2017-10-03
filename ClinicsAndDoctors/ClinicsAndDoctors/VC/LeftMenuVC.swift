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
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarIm.layer.cornerRadius = avatarIm.frame.width/2
        // Do any additional setup after loading the view.
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
