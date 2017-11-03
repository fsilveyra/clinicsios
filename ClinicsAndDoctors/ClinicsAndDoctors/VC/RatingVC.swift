//
//  RatingVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 09/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding


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
    @IBOutlet weak var scrollView:TPKeyboardAvoidingScrollView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    var rating = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitBt.layer.cornerRadius = 5
        avatarClinicIm.layer.cornerRadius = avatarClinicIm.frame.width/2
        avatarClinicIm.layer.borderColor = UIColor.darkGray.cgColor
        


        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        self.scrollView.contentInset = UIEdgeInsetsMake(0,0,0,0);

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem?.title = "Back"
        self.navigationController?.navigationBar.isHidden = false
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
    
    @IBAction func SubmitRating(_ sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
    }



}
