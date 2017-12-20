//
//  SearchView.swift
//  ClinicsAndDoctors
//
//  Created by Osmely Fernandez on 28/11/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import PromiseKit
import MapKit

class SearchView: UIView , UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITextFieldDelegate {

    var clinicId:String? = nil
    private var view: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!

    var clinics = [ClinicModel]()
    var doctors = [DoctorModel]()

    var onClose:(() -> Void)? = nil
    var onSelectItem:((String, String) -> Void)? = nil

    override init(frame: CGRect){
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup(){
        view = addSubViewFromNib()
        self.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.clear

        let classBundle = Bundle(for: DoctorTableCell.self)
        let nibProd = UINib(nibName:"DoctorTableCell", bundle:classBundle)
        self.tableView.register(nibProd, forCellReuseIdentifier:"DoctorTableCell")

        let classBundle2 = Bundle(for: ClinicTableCell.self)
        let nibProd2 = UINib(nibName:"ClinicTableCell", bundle:classBundle2)
        self.tableView.register(nibProd2, forCellReuseIdentifier:"ClinicTableCell")

        textField.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self

        if let _ = self.clinicId{
            localDoctorSearch(text: "")
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        view.bounds = self.bounds
        view.frame.origin = CGPoint.zero

    }

    @IBAction func closeAction(_ sender: Any) {
        onClose?()
    }

    @IBAction func searchAction(_ sender: Any) {
        self.view.endEditing(true)
        self.search(text: self.textField.text ?? "")
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.search(text: self.textField.text ?? "")
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.clinics = [ClinicModel]()
        self.doctors = [DoctorModel]()
        self.tableView.reloadData()
    }

}



//====================================================
// MARK: - Search
//====================================================

extension SearchView {

    func loadClinics(radius: Int, specialityId: String? = nil) -> Promise<Void>{

        return ISClient.sharedInstance.getClinics(latitude: 0,
                                                  longitude: 0,
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


    func localDoctorSearch(text:String){
        self.clinics = [ClinicModel]()
        self.doctors = [DoctorModel]()

        self.tableView.reloadData()

        guard let clincId = self.clinicId else {return}

        if let clinic = ClinicModel.by(id: clincId){
             let doctors = clinic.getDoctors()

            if text.isEmpty {
                self.doctors = doctors
            }else{
                self.doctors = doctors.filter({ (doc) -> Bool in
                    return (doc.full_name.lowercased().range(of:text) != nil)
                })
            }

            self.tableView.reloadData()

        }
    }


    func search(text:String){
        
        if text.isEmpty {return}


        NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)

            self.loadClinics(radius: 100000000, specialityId: nil)
            .then {
                self.loadDoctors(specialityId:nil, clinicId: nil)
                }.then {

                    ISClient.sharedInstance.search(keyword: text, clinicId: self.clinicId)
            }.then {[weak self] items -> Void in

                self?.clinics = [ClinicModel]()
                self?.doctors = [DoctorModel]()

                for item in items {
                    
                    if let clinic = item.clinicData {
                        self?.clinics.append(clinic)
                    }
                    if let doctor = item.doctorData {
                        self?.doctors.append(doctor)
                    }
                }

                self?.tableView.reloadData()

            }.always {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }.catch { error in
                if let e: LPError = error as? LPError { e.show() }
        }
    }



    func searchInDoctorOfClinic(clinicId:String, text:String){
        if text.isEmpty {return}


        NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)

        self.loadClinics(radius: UserModel.radiusLocationMeters, specialityId: nil)
            .then {
                self.loadDoctors(specialityId:nil, clinicId: nil)
            }.then {

                ISClient.sharedInstance.search(keyword: text)
            }.then {[weak self] items -> Void in

                self?.clinics = [ClinicModel]()
                self?.doctors = [DoctorModel]()
                for item in items {
                    if let clinic = item.clinicData {
                        self?.clinics.append(clinic)
                    }
                    if let doctor = item.doctorData {
                        self?.doctors.append(doctor)
                    }
                }

                self?.tableView.reloadData()

            }.always {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }.catch { error in
                if let e: LPError = error as? LPError { e.show() }
        }
    }
}

//====================================================
// MARK: - TableView Delegates
//====================================================

extension SearchView {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.doctors.count + self.clinics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < self.clinics.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClinicTableCell", for: indexPath) as! ClinicTableCell
            cell.updateWith(clinic: self.clinics[indexPath.row])
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorTableCell", for: indexPath) as! DoctorTableCell

            cell.updateWith(doctor: self.doctors[indexPath.row - self.clinics.count])
            return cell
        }
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row < self.clinics.count {
            self.onSelectItem?(self.clinics[indexPath.row].id, "clinic")
        }else{
            self.onSelectItem?(self.doctors[indexPath.row - self.clinics.count].id, "doctor")
        }
    }



}


