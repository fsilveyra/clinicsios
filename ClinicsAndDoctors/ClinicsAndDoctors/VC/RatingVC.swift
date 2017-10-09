//
//  RatingVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 09/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class RatingVC: UIViewController {
    @IBOutlet weak var avatarClinicIm:UIImageView!
    @IBOutlet weak var submitBt:UIButton!
    @IBOutlet weak var titleLb:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitBt.layer.cornerRadius = 5
        avatarClinicIm.layer.cornerRadius = avatarClinicIm.frame.width/2
        avatarClinicIm.layer.borderColor = UIColor.darkGray.cgColor
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func GoBack(_ sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
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
