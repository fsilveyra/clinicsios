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
    @IBOutlet weak var face1:UIButton!
    @IBOutlet weak var face2:UIButton!
    @IBOutlet weak var face3:UIButton!
    @IBOutlet weak var face4:UIButton!
    @IBOutlet weak var face5:UIButton!
    @IBOutlet weak var option1Lb:UILabel!
    @IBOutlet weak var option2Lb:UILabel!
    @IBOutlet weak var option3Lb:UILabel!
    @IBOutlet weak var option1Bt:UIButton!
    @IBOutlet weak var option2Bt:UIButton!
    @IBOutlet weak var option3Bt:UIButton!
    @IBOutlet weak var option4Bt:UIButton!
    
    
    var rating = 0
    
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

    // MARK: - Actions
    @IBAction func GoBack(_ sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func Face1(_ sender: AnyObject){
        face1.tintColor = UIColor(red: 35/255, green: 160/255, blue: 150/255, alpha: 1)
        face2.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        face3.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        face4.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        face5.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        rating = 1
        option1Lb.text = "The waiting was too long."
        option2Lb.text = "The attention wasn’t good."
        option3Lb.text = "It was too expensive."
    }
    
    @IBAction func Face2(_ sender: AnyObject){
        face1.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        face2.tintColor = UIColor(red: 35/255, green: 160/255, blue: 150/255, alpha: 1)
        face3.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        face4.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        face5.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        rating = 2
        option1Lb.text = "The waiting was too long."
        option2Lb.text = "The attention wasn’t good."
        option3Lb.text = "It was too expensive."
    }
    
    @IBAction func Face3(_ sender: AnyObject){
        face1.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        face2.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        face3.tintColor = UIColor(red: 35/255, green: 160/255, blue: 150/255, alpha: 1)
        face4.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        face5.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        rating = 3
        option1Lb.text = "The waiting was too long."
        option2Lb.text = "The attention wasn’t good."
        option3Lb.text = "It was too expensive."
    }
    
    @IBAction func Face4(_ sender: AnyObject){
        face1.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        face2.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        face3.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        face4.tintColor = UIColor(red: 35/255, green: 160/255, blue: 150/255, alpha: 1)
        face5.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        rating = 4
        option1Lb.text = "The attention was so good."
        option2Lb.text = "The places is clean and modern."
        option3Lb.text = "The waiting was short."
        
        
        
    }
    
    @IBAction func Face5(_ sender: AnyObject){
        face1.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        face2.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        face3.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        face4.tintColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)
        face5.tintColor = UIColor(red: 35/255, green: 160/255, blue: 150/255, alpha: 1)
        rating = 5
        option1Lb.text = "The attention was so good."
        option2Lb.text = "The places is clean and modern."
        option3Lb.text = "The waiting was short."
    }
    
    @IBAction func AddRemoveOptions(_ sender: AnyObject){
        let optionBt = sender as! UIButton
        let tag = optionBt.tag
        switch tag {
        case 0:
            optionBt.setImage(#imageLiteral(resourceName: "icon_ok"), for: .normal)
            optionBt.tag = 1
        default:
            optionBt.setImage(#imageLiteral(resourceName: "grayEllipse"), for: .normal)
            optionBt.tag = 0
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
