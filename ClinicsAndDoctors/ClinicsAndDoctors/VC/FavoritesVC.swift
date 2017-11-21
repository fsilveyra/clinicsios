//
//  FavoritesVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 08/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import PromiseKit
import MapKit

class FavoritesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var doctorsBt:UIButton!
    @IBOutlet weak var clinicsBt:UIButton!
    @IBOutlet weak var subView:UIView!
    @IBOutlet weak var myTableView:UITableView!
    @IBOutlet weak var defaultView: UIView!
    @IBOutlet weak var defaultText: UILabel!

    var doctorsSelected = true
    var clinics = [ClinicModel]()
    var doctors = [DoctorModel]()

    func translateStaticInterface(){
        self.navigationItem.title = "FAVORITES".localized
        doctorsBt.setTitle("Doctors".localized, for: .normal)
        clinicsBt.setTitle("Clinics".localized, for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        translateStaticInterface()

        myTableView.frame.origin.y = doctorsBt.frame.maxY
        myTableView.frame.size.height = view.frame.maxY - myTableView.frame.minY

        let classBundle = Bundle(for: DoctorTableCell.self)
        let nibProd = UINib(nibName:"DoctorTableCell", bundle:classBundle)
        self.myTableView.register(nibProd, forCellReuseIdentifier:"DoctorTableCell")

        let classBundle2 = Bundle(for: ClinicTableCell.self)
        let nibProd2 = UINib(nibName:"ClinicTableCell", bundle:classBundle2)
        self.myTableView.register(nibProd2, forCellReuseIdentifier:"ClinicTableCell")



        if #available(iOS 11.0, *) {
            myTableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        myTableView.contentInset = UIEdgeInsetsMake(0,0,0,0);


        self.myTableView.delegate = self
        self.myTableView.dataSource = self

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.defaultView.frame = self.myTableView.frame
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Actions
    @IBAction func BackView(_ sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ShowDoctors(_ sender: AnyObject){
        self.doctorsSelected = true
        self.myTableView.reloadData()
        UIView.animate(withDuration: 0.3) {
            self.subView.frame.size.width = self.doctorsBt.frame.size.width
            self.subView.center.x = self.doctorsBt.center.x
        }

        updateDefaultView()

    }

    @IBAction func ShowClinics(_ sender: AnyObject){
        self.doctorsSelected = false
        self.myTableView.reloadData()
        UIView.animate(withDuration: 0.3) {
            self.subView.frame.size.width = self.clinicsBt.frame.size.width
            self.subView.center.x = self.clinicsBt.center.x
        }

        updateDefaultView()
    }

    func updateDefaultView(){
        self.view.bringSubview(toFront: self.defaultView)
        self.defaultView.isHidden = true

        if self.doctorsSelected {
            if self.doctors.count == 0 {
                self.defaultText.text = "You don't have favorite clinics yet.".localized
                self.defaultView.isHidden = false
            }
        }else{
            if self.clinics.count == 0 {
                self.defaultText.text = "You don't have favorite doctors yet.".localized
                self.defaultView.isHidden = false
            }
        }

    }

}

//====================================================
// MARK: - Data
//====================================================

extension FavoritesVC {

    func reload(){

        NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)

        self.loadClinics(radius: 100000000).then {
                self.loadDoctors(specialityId:nil, clinicId: nil)
            }.then { _ -> Void in

                self.doctors = DoctorModel.doctors.filter { (doc) -> Bool in return doc.is_favorite }
                self.clinics = ClinicModel.clinics.filter { (cli) -> Bool in return cli.is_favorite }
                self.myTableView.reloadData()

                self.updateDefaultView()

            }.always {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }.catch { error in

                if let e: LPError = error as? LPError { e.show() }

                DispatchQueue.main.asyncAfter(
                    deadline: DispatchTime.now() + 1, execute: {

                        let alert = UIAlertController(title:"ClinicsAndDoctors", message: "Error loading from server. Please, try again.".localized, preferredStyle: .alert)

                        alert.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: {[weak self] action in
                            self?.reload()
                        }))

                        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: {[weak self] action in
                            self?.navigationController?.popViewController(animated: true)
                        }))

                        self.present(alert, animated: true, completion: nil)
                })
        }



    }

    func loadClinics(radius: Int, specialityId: String? = nil) -> Promise<Void>{

        let location = UserModel.mylocation ?? CLLocation(latitude: 0, longitude: 0)

        return ISClient.sharedInstance.getClinics(latitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude,
                                                  radius: radius,
                                                  specialty_id: specialityId)
            .then { clist -> Void in
                ClinicModel.clinics = clist
            }
    }

    func loadDoctors(specialityId: String?, clinicId:String?) -> Promise<Void>{
        return ISClient.sharedInstance.getDoctors(specialty_id: specialityId, clinic_id:clinicId)
            .then { doctors -> Void in
                DoctorModel.doctors = doctors
        }
    }

}


//====================================================
// MARK: - TableView Delegates
//====================================================

extension FavoritesVC {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.doctorsSelected ? self.doctors.count : self.clinics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.doctorsSelected == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClinicTableCell", for: indexPath) as! ClinicTableCell
                cell.updateWith(clinic: self.clinics[indexPath.row])
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorTableCell", for: indexPath) as! DoctorTableCell

            cell.updateWith(doctor: self.doctors[indexPath.row])
            return cell
        }
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if self.doctorsSelected == false {
            let vc = storyboard.instantiateViewController(withIdentifier: "ClinincDetailVC") as! ClinincDetailVC
            vc.clinicId = self.clinics[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = storyboard.instantiateViewController(withIdentifier: "DoctorDetailVC") as! DoctorDetailVC
            vc.docId = self.doctors[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}



