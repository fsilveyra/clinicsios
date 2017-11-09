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

    var doctorId:String?
    var clinicId:String?

    @IBOutlet weak var itemTitleLbl: UILabel!
    @IBOutlet var faces: [UIButton]!
    @IBOutlet var optionsLb: [UILabel]!
    @IBOutlet var optionsBtns: [UIButton]!

    @IBOutlet weak var avatarClinicIm:RoundedImageView!
    @IBOutlet weak var submitBt:UIButton!
    @IBOutlet weak var titleLb:UILabel!

    @IBOutlet var commentsView: [UIView]!

    @IBOutlet weak var scrollView:TPKeyboardAvoidingScrollView!
    @IBOutlet weak var questionLbl: UILabel!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let selectedFaceColor:UIColor = UIColor(red: 35/255, green: 160/255, blue: 150/255, alpha: 1)
    let unselectedFaceColor:UIColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)

    var rating = 3 {
        didSet{
            selectRatin(rating)
        }
    }

    var selectedOption = -1 {
        didSet {
            selectOption(selectedOption)
        }
    }

    let optionsText = [
        ["The waiting was too long.",
        "The attention wasn’t good.",
        "It was too expensive."],

        ["The attention was so good.",
         "The places is clean and modern.",
         "The waiting was short."]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        self.scrollView.contentInset = UIEdgeInsetsMake(0,0,0,0);

        self.updateWithData()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem?.title = "Back"
        self.navigationController?.navigationBar.isHidden = false

        self.selectRatin(3)
        self.selectedOption = -1
    }

    func updateWithData(){
        if let doctorId = self.doctorId {
            if let doctor = DoctorModel.by(id: doctorId){
                if let url = URL(string: doctor.profile_picture){
                    avatarClinicIm.url = url
                }
                itemTitleLbl.text = doctor.full_name
            }

        }else if let clinicId = self.clinicId {
            if let clinic = ClinicModel.by(id: clinicId){
                if let url = URL(string: clinic.profile_picture){
                    avatarClinicIm.url = url
                }
                itemTitleLbl.text = clinic.full_name
            }
        }
    }

    func faceWith(tag: Int) -> UIButton?{
        return self.faces.filter { (b) -> Bool in return b.tag == tag}.first
    }

    func optionWith(tag: Int) -> UIButton?{
        return self.optionsBtns.filter { (b) -> Bool in return b.tag == tag}.first
    }

    private func selectOption(_ r :Int){
        for op in optionsBtns {
            op.setImage(#imageLiteral(resourceName: "icon_ok"), for: .selected)
            op.setImage(#imageLiteral(resourceName: "grayEllipse"), for: .normal)
            op.isSelected =  (op.tag == r)
        }

        for c in commentsView {c.isHidden = (r != 3)}

        self.submitBt.isHidden = (self.selectedOption < 0 || self.selectedOption > 3)

    }

    private func selectRatin(_ r :Int){

        for f in faces { f.tintColor = self.unselectedFaceColor }

        faceWith(tag: r - 1)!.tintColor = selectedFaceColor

        let t = r - 1

        if t >= 3 {
            questionLbl.text = "Tell us what did you like?"
            for (index,lb) in optionsLb.enumerated() { lb.text = optionsText[0][index] }
        }else{
            for (index,lb) in optionsLb.enumerated() { lb.text = optionsText[1][index] }
            questionLbl.text = "Tell us what we can improve?"
        }

        self.selectedOption = -1
    }


    @IBAction func optionsAction(_ sender: UIButton) {
        self.selectedOption = sender.tag
    }

    @IBAction func facesAction(_ sender: UIButton) {
        self.rating = sender.tag + 1
    }

    @IBAction func SubmitRating(_ sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
    }

}
