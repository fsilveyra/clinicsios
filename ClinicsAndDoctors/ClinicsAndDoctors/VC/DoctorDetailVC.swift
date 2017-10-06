//
//  DoctorDetailVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 06/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class DoctorDetailVC: UIViewController {
    @IBOutlet weak var loadingIm:UIImageView!
    @IBOutlet weak var doctorAvatarIm:UIImageView!
    @IBOutlet weak var gentilizeLb:UILabel!
    @IBOutlet weak var addressLb:UILabel!
    @IBOutlet weak var especialityBt:UIButton!
    @IBOutlet weak var distanceLb:UILabel!
    @IBOutlet weak var ratingLb:UILabel!
    @IBOutlet weak var phoneBt:UIButton!
    @IBOutlet weak var addFavoriteBt:UIButton!
    @IBOutlet weak var rateView:UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        CreateGradienBackGround(view: self.view)
        addFavoriteBt.layer.cornerRadius = 10
        phoneBt.layer.cornerRadius = 10
        doctorAvatarIm.layer.cornerRadius = doctorAvatarIm.frame.width/2
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func BackView(_ sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ShowHideRateView(_ sender: AnyObject){
        if rateView.isHidden {
            rateView.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.rateView.frame.origin.x -= self.rateView.frame.width
            })
        }
        else{
            
            UIView.animate(withDuration: 0.5, animations: {
                self.rateView.frame.origin.x += self.rateView.frame.width
            }, completion: { _ in
                self.rateView.isHidden = true
            })
        }
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
