//
//  ReviewsVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 08/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import Cosmos
import NVActivityIndicatorView


class ReviewsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var loadingIm:UIImageView!
    @IBOutlet weak var doctorAvatarIm:RoundedImageView!
    @IBOutlet weak var nameLb:UILabel!
    @IBOutlet weak var myTableView:UITableView!
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var rateBtn: RoundedButton!

    var reviews = [ReviewModel]()
    var docId = ""
    var clinicId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        CreateGradienBackGround(view: self.view)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.docId.isEmpty {
            if let clinic = ClinicModel.by(id: self.clinicId){
                self.updateWith(clinic: clinic)
            }
        }else{
            if let doctor = DoctorModel.by(id: self.docId){
                self.updateWith(doctor: doctor)
            }
        }

        self.loadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    private func updateWith(doctor: DoctorModel){
        if let url = URL(string: doctor.profile_picture){
            self.doctorAvatarIm.url = url
        }

        self.nameLb.text = doctor.full_name
        self.rateView.rating = doctor.rating
        if doctor.is_rated {
            self.rateBtn.setTitle("UPDATE RATING".localized, for: .normal)
        }else{
            self.rateBtn.setTitle("RATE DOCTOR".localized, for: .normal)
        }

    }

    private func updateWith(clinic: ClinicModel){
        if let url = URL(string: clinic.profile_picture){
            self.doctorAvatarIm.url = url
        }

        self.nameLb.text = clinic.full_name
        self.rateView.rating = clinic.rating

        if clinic.is_rated {
            self.rateBtn.setTitle("UPDATE RATING".localized, for: .normal)
        }else{
            self.rateBtn.setTitle("RATE CLINIC".localized, for: .normal)
        }

    }


    func loadData(){
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)

        let idObj = self.docId.isEmpty ? self.clinicId : self.docId
        let objType = self.docId.isEmpty ? "clinic" : "doctor"

        ISClient.sharedInstance.getReviews(clinicOrDoctorId: idObj, objType: objType)
            .then { reviews -> Void in

                self.reviews = reviews
                self.myTableView.reloadData()

            }.always {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }.catch { error in
                if let e: LPError = error as? LPError { e.show() }
        }

    }


    @IBAction func rateAction(_ sender: Any) {


        if UserModel.currentUser != nil {
            self.performSegue(withIdentifier: "toRating", sender: nil)
        }
        else{

            self.SwiftMessageAlert(layout: .cardView, theme: .info, title: "ClinicsAndDoctors", body: "Must be logged in first".localized)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {[weak self] in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! ViewController
                vc.futureVC = "RatingVC"

                if (self?.docId.isEmpty)! {
                    vc.futureClinicId = self?.clinicId
                }else{
                    vc.futureDoctorId = self?.docId
                }

                self?.navigationController?.pushViewController(vc,
                                                               animated: true)
            })

        }

    }

    // MARK: - Actions
    
    @IBAction func BackView(_ sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - TableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        cell.updateWithData(self.reviews[indexPath.row])
        return cell
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toRating" {
            let vc:RatingVC = segue.destination as! RatingVC
            if self.docId.isEmpty {
                vc.clinicId = self.clinicId
            }else{
                vc.doctorId = self.docId
            }

        }

    }

}
