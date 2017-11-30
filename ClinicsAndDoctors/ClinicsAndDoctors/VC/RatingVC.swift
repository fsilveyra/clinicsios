//
//  RatingVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 09/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import NVActivityIndicatorView

class RatingVC: UIViewController {

    var doctorId:String?
    var clinicId:String?
    var reason:String = ""

    @IBOutlet weak var itemTitleLbl: UILabel!
    @IBOutlet var faces: [UIButton]!
    @IBOutlet var optionsLb: [UILabel]!
    @IBOutlet var optionsBtns: [UIButton]!
    @IBOutlet weak var commentLbl: UILabel!

    @IBOutlet weak var avatarClinicIm:RoundedImageView!
    @IBOutlet weak var submitBt:UIButton!
    @IBOutlet weak var titleLb:UILabel!

    @IBOutlet weak var commentText: UITextField!
    @IBOutlet var commentsView: [UIView]!

    @IBOutlet weak var scrollView:TPKeyboardAvoidingScrollView!
    @IBOutlet weak var questionLbl: UILabel!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let selectedFaceColor:UIColor = UIColor(red: 35/255, green: 160/255, blue: 150/255, alpha: 1)
    let unselectedFaceColor:UIColor = UIColor(red: 19/255, green: 41/255, blue: 61/255, alpha: 1)

    var rating = 5 {
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
        ["The waiting was too long.".localized,
        "The attention wasn’t good.".localized,
        "It was too expensive.".localized],

        ["The attention was so good.".localized,
         "The places is clean and modern.".localized,
         "The waiting was short.".localized]
    ]

    func translateStaticInterface(){
        submitBt.setTitle("SUBMIT".localized, for: .normal)
        titleLb.text = "    " + "Rate Your Experience At:".localized
        commentLbl.text = "Leave a comment:".localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        translateStaticInterface()

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
        self.navigationItem.backBarButtonItem?.title = "Back".localized
        self.navigationController?.navigationBar.isHidden = false

        tryLoadRate()
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
            questionLbl.text = "Tell us what did you like?".localized
            for (index,lb) in optionsLb.enumerated() { lb.text = optionsText[1][index] }
        }else{
            for (index,lb) in optionsLb.enumerated() { lb.text = optionsText[0][index] }
            questionLbl.text = "Tell us what we can improve?".localized
        }

        self.selectedOption = -1
    }


    @IBAction func optionsAction(_ sender: UIButton) {
        self.selectedOption = sender.tag
        self.reason = (sender.tag < 3) ? optionsLb[sender.tag].text! : "Other"
    }

    @IBAction func facesAction(_ sender: UIButton) {
        self.rating = sender.tag + 1
    }



    func tryLoadRate(){

        let id = (self.clinicId ?? self.doctorId)!
        let isClinic = (self.clinicId != nil)
        var rated = false

        if isClinic {
            if ClinicModel.isLocalRated(cId: id) {
                let (value, option, comment) =  ClinicModel.getRateValues(cId: id)
                self.selectRatin(value)
                self.selectedOption = option
                commentText.text = comment
                rated = true
            }

        }else{
            if DoctorModel.isLocalRated(docId: id) {
                let (value, option, comment) =  DoctorModel.getRateValues(docId: id)
                self.selectRatin(value)
                self.selectedOption = option
                commentText.text = comment
                rated = true
            }
        }

        if rated == false {
            self.selectRatin(5)
            self.selectedOption = 0
            commentText.text = ""
        }
    }

    @IBAction func SubmitRating(_ sender: AnyObject){


        NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)

        let id = (self.clinicId ?? self.doctorId)!
        let isClinic = (self.clinicId != nil)

        let content = (self.selectedOption == 3) ? commentText.text : self.reason

        ISClient.sharedInstance.sendRating(clinicOrDoctorId: id, objType: (isClinic ? "clinic" : "doctor"), value: Float(self.rating), reason: self.reason, comment: content)

            .then {[weak self] user -> Void in

                if isClinic {
                    ClinicModel.setRated(cId: (self?.clinicId)!,
                                         value: (self?.rating)!,
                                         option: (self?.selectedOption)!,
                                         otherComment: content!)
                }else{
                    DoctorModel.setRated(docId: (self?.doctorId)!,
                                         value: (self?.rating)!,
                                         option: (self?.selectedOption)!,
                                         otherComment: content!)

                }

                self?.SwiftMessageAlert(layout: .cardView, theme: .success, title: "", body: "Rating Successful".localized)

                self?.navigationController?.popViewController(animated: true)

            }.always {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                self.view.endEditing(true)

            }.catch { error in
                if let e: LPError = error as? LPError {
                    e.show()
                }
        }



    }

}
