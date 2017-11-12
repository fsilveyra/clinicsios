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

class DoctorDetailVC: UIViewController {
    @IBOutlet weak var loadingIm:UIImageView!
    @IBOutlet weak var doctorAvatarIm:RoundedImageView!
    @IBOutlet weak var nameLb:UILabel!
    @IBOutlet weak var gentilizeLb:UILabel!
    @IBOutlet weak var addressLb:UILabel!
    @IBOutlet weak var especialityLb:UILabel!
    @IBOutlet weak var distanceLb:UILabel!
    @IBOutlet weak var phoneBt:UIButton!
    @IBOutlet weak var addFavoriteBt:UIButton!
    @IBOutlet weak var rateMenuView:UIView!
    @IBOutlet weak var rMenuBtn: UIBarButtonItem!
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var rateDocBtn: UIButton!

    @IBOutlet weak var gotoClinicPageBtn: UIButton!

    @IBOutlet weak var rMenuDistance: NSLayoutConstraint!

    var rMenuBtnVisible = true
    var docId = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        CreateGradienBackGround(view: self.view)

        if let doctor = DoctorModel.by(id: self.docId){
            self.updateWith(doctor: doctor)
        }

        if rMenuBtnVisible == false {
            self.gotoClinicPageBtn.removeFromSuperview()
        }

    }

    private func updateWith(doctor: DoctorModel){

        if let url = URL(string: doctor.profile_picture){
            self.doctorAvatarIm.url = url
        }

        self.nameLb.text = doctor.full_name
        self.gentilizeLb.text = doctor.nationality
        self.addressLb.text = ""
        self.rateView.rating = doctor.rating

        self.especialityLb.text = ""
        if let esp = SpecialityModel.by(id: doctor.idSpecialty){
            self.especialityLb.text = esp.name
        }

        if let clinic = ClinicModel.by(id: doctor.idClinic) {
            //self.clinicNameLbl.text = clinic.full_name

            if let loc = UserModel.currentUser?.mylocation {
                let clinicCoord = CLLocation(latitude: clinic.latitude, longitude: clinic.longitude)
                let distance = loc.distance(from: clinicCoord) / 1000.0
                self.distanceLb.text = "\(distance.rounded(toPlaces: 2)) Km"
            }
        }

        if doctor.phone_number.isEmpty {
            self.phoneBt.isHidden = true
        }else{
            self.phoneBt.setTitle(" " + doctor.phone_number, for: .normal)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false

        if DoctorModel.isRated(docId: self.docId) {

            if self.rateDocBtn != nil{
                self.rateDocBtn.removeFromSuperview()
            }

            if rMenuBtnVisible == false {
                self.navigationItem.rightBarButtonItem = nil
                
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        showRMenu(false)
    }


    // MARK: - Actions

    @IBAction func BackView(_ sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
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

    @IBAction func GoToClinicPage(_ sender: AnyObject){
        showRMenu(false)
        self.performSegue(withIdentifier: "toClinicDetails", sender: nil)
    }

    @IBAction func rateBtnAction(_ sender: Any) {
        showRMenu(false)

        if UserModel.currentUser != nil {
            self.performSegue(withIdentifier: "toRating", sender: nil)
        }
        else{

            self.SwiftMessageAlert(layout: .cardView, theme: .info, title: "Clinics and Doctors", body: "Must be logged in first")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! ViewController
            vc.futureVC = "RatingVC"
            vc.futureDoctorId = self.docId

            navigationController?.pushViewController(vc,
                                                     animated: true)

        }
    }

    @IBAction func phoneBtnAction(_ sender: Any) {

        guard let doctor = DoctorModel.by(id: self.docId) else { return }

        var strPhoneNumber = doctor.phone_number!
        strPhoneNumber = strPhoneNumber.replacingOccurrences(of: " ", with: "")
        strPhoneNumber = strPhoneNumber.replacingOccurrences(of: "-", with: "")


        if let phoneCallURL:URL = URL(string: "tel:\(strPhoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                let alertController = UIAlertController(title: "ClinicsAndDoctors", message: "Are you sure you want to call \n\(doctor.phone_number!)?", preferredStyle: .alert)
                let yesPressed = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    UIApplication.shared.openURL(phoneCallURL)
                })
                let noPressed = UIAlertAction(title: "No", style: .default, handler: { (action) in

                })
                alertController.addAction(yesPressed)
                alertController.addAction(noPressed)
                present(alertController, animated: true, completion: nil)
            }
        }

    }


    // MARK: - Navigation
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
