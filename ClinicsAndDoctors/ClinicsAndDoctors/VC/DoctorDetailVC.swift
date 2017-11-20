//
//  DoctorDetailVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 06/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import MapKit
import Cosmos
import NVActivityIndicatorView

class DoctorDetailVC: UIViewController {
    @IBOutlet weak var loadingIm:UIImageView!
    @IBOutlet weak var doctorAvatarIm:RoundedImageView!
    @IBOutlet weak var nameLb:UILabel!
    @IBOutlet weak var especialityLb:UILabel!
    @IBOutlet weak var phoneBt:UIButton!
    @IBOutlet weak var addFavoriteBt:UIButton!
    @IBOutlet weak var rateMenuView:UIView!
    @IBOutlet weak var rMenuBtn: UIBarButtonItem!
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var rateDocBtn: UIButton!
    @IBOutlet weak var rMenuDistance: NSLayoutConstraint!
    @IBOutlet weak var ubicBtn: RoundedButton!
    @IBOutlet weak var clinicBtn: RoundedButton!

    var rMenuBtnVisible = true
    var docId = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        CreateGradienBackGround(view: self.view)
        self.addFavoriteBt.setImage(UIImage(named:"ic_fav_off"), for: .normal)
        self.addFavoriteBt.setImage(UIImage(named:"ic_favorite_profile"), for: .selected)
    }

    private func updateWith(doctor: DoctorModel){

        if let url = URL(string: doctor.profile_picture){
            self.doctorAvatarIm.url = url
        }

        self.nameLb.text = doctor.full_name
        self.rateView.rating = doctor.rating

        self.especialityLb.text = ""
        if let esp = SpecialityModel.by(id: doctor.idSpecialty){
            self.especialityLb.text = esp.name
        }

        if let clinic = ClinicModel.by(id: doctor.idClinic) {
            clinicBtn.isHidden = false
            clinicBtn.setTitle(clinic.full_name , for: .normal)
        }else{
            clinicBtn.isHidden = true
        }

        self.phoneBt.isHidden = doctor.phone_number.isEmpty
        self.addFavoriteBt.isSelected = UserModel.currentUser != nil && doctor.is_favorite
        self.clinicBtn.isHidden = !rMenuBtnVisible
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false

        if let doctor = DoctorModel.by(id: self.docId){
            self.updateWith(doctor: doctor)
        }

        updateRmenu()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        showRMenu(false)
    }

    @IBAction func BackView(_ sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func phoneBtnAction(_ sender: Any) {
        guard let doctor = DoctorModel.by(id: self.docId) else { return }
        var strPhoneNumber = doctor.phone_number!
        strPhoneNumber = strPhoneNumber.replacingOccurrences(of: " ", with: "")
        strPhoneNumber = strPhoneNumber.replacingOccurrences(of: "-", with: "")

        if let phoneCallURL:URL = URL(string: "tel:\(strPhoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                let alertController = UIAlertController(title: "ClinicsAndDoctors", message: "Are you sure you want to call".localized + " \n\(doctor.phone_number!)?", preferredStyle: .alert)
                let yesPressed = UIAlertAction(title: "Yes".localized, style: .default, handler: { (action) in
                    UIApplication.shared.openURL(phoneCallURL)
                })
                let noPressed = UIAlertAction(title: "No".localized, style: .default, handler: { (action) in

                })
                alertController.addAction(yesPressed)
                alertController.addAction(noPressed)
                present(alertController, animated: true, completion: nil)
            }
        }

    }

    @IBAction func gotoClinicAction(_ sender: Any) {
        self.performSegue(withIdentifier: "toClinicDetails", sender: nil)
    }
}



// ==========================================
// MARK: - Navigation
// ==========================================

extension DoctorDetailVC {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toClinicDetails" {
            let vc:ClinincDetailVC = segue.destination as! ClinincDetailVC
            if let doctor = DoctorModel.by(id: self.docId){
                vc.clinicId = doctor.idClinic
            }

        }else if segue.identifier == "toReviews" {
            let vc:ReviewsVC = segue.destination as! ReviewsVC
            vc.docId = self.docId

        }else if segue.identifier == "toRating" {
            let vc:RatingVC = segue.destination as! RatingVC
            vc.doctorId = self.docId
        }

    }


}



// ==========================================
// MARK: - RMenu
// ==========================================

extension DoctorDetailVC {

    func updateRmenu(){

        if DoctorModel.isRated(docId: self.docId) || rMenuBtnVisible == false {
            if self.rateDocBtn != nil{
                self.rateDocBtn.removeFromSuperview()
                self.navigationItem.rightBarButtonItem = nil
            }
        }

    }


    func showRMenu(_ show : Bool){
        if show {
            self.view.bringSubview(toFront: self.rateMenuView)
            rateMenuView.isHidden = false

            self.rMenuDistance.constant = self.rateMenuView.frame.size.width
            UIView.animate(withDuration: 0.3, animations: {[weak self] in
                self?.view.layoutIfNeeded()
            })
        }
        else{
            self.rMenuDistance.constant = 0
            UIView.animate(withDuration: 0.3, animations: {[weak self] in
                self?.view.layoutIfNeeded()
                }, completion: { _ in
                    self.rateMenuView.isHidden = true
            })
        }

    }

    @IBAction func ShowHideRateView(_ sender: AnyObject){
        showRMenu(rateMenuView.isHidden)
    }

    @IBAction func rateBtnAction(_ sender: Any) {
        showRMenu(false)

        if UserModel.currentUser != nil {
            self.performSegue(withIdentifier: "toRating", sender: nil)
        }
        else{

            self.SwiftMessageAlert(layout: .cardView, theme: .info, title: "ClinicsAndDoctors", body: "Must be logged in first".localized)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {[weak self] in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! ViewController
                vc.futureVC = "RatingVC"
                vc.futureDoctorId = self?.docId

                self?.navigationController?.pushViewController(vc,
                                                               animated: true)
            })

        }
    }

}



// ==========================================
// MARK: - Favorites
// ==========================================

extension DoctorDetailVC {

    @IBAction func addToFavAction(_ sender: Any) {

        self.showRMenu(false)

        if UserModel.currentUser != nil {
            addOrRemoveFav()
        }else{

            self.SwiftMessageAlert(layout: .cardView, theme: .info, title: "ClinicsAndDoctors", body: "Must be logged in first".localized)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {[weak self] in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! ViewController
                self?.navigationController?.pushViewController(vc, animated: true)
            })

        }
    }


    func addOrRemoveFav() {

        guard let doctor = DoctorModel.by(id: self.docId) else { return }

        NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)

        if doctor.is_favorite {

            ISClient.sharedInstance.removeFavorite(clinicOrDoctorId: self.docId, objType: "doctor")
                .then { ok -> Void in

                    if ok {
                        self.SwiftMessageAlert(layout: .cardView, theme: .success, title: "ClinicsAndDoctors", body: "Removed from favorites".localized)

                        DoctorModel.by(id: self.docId)?.is_favorite = false
                        self.updateWith(doctor:DoctorModel.by(id: self.docId)!)
                    }

                }.always {
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                }.catch { error in
                    if let e: LPError = error as? LPError { e.show() }
            }


        }else{

            ISClient.sharedInstance.addFavorite(clinicOrDoctorId: self.docId, objType: "doctor")
                .then { ok -> Void in

                    if ok {
                        self.SwiftMessageAlert(layout: .cardView, theme: .success, title: "ClinicsAndDoctors", body: "Added to favorites".localized)

                        DoctorModel.by(id: self.docId)?.is_favorite = true
                        self.updateWith(doctor:DoctorModel.by(id: self.docId)!)
                    }

                }.always {
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                }.catch { error in
                    if let e: LPError = error as? LPError { e.show() }
            }

        }

    }

}

