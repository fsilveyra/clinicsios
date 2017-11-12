//
//  ClinincDetailVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 09/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import MapKit
import Cosmos
import NVActivityIndicatorView
import PromiseKit


class ClinincDetailVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var avatarClinicIm:RoundedImageView!
    @IBOutlet weak var nameClinicLb:UILabel!
    @IBOutlet weak var centerLb:UILabel!
    @IBOutlet weak var addressLb:UILabel!
    @IBOutlet weak var directionBt:UIButton!
    @IBOutlet weak var callBt:UIButton!
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var rMenuDistance: NSLayoutConstraint!
    @IBOutlet weak var rateClinicBtn: UIButton!


    @IBOutlet weak var rMenuView: UIView!
    @IBOutlet weak var specialitiesCollection:UICollectionView!
    @IBOutlet weak var myTableView:UITableView!
    @IBOutlet weak var separetorView:UIView!

    var specialitysNames = ["All"]
    var currentSelectedEspec = 0

    var clinicId = ""
    var doctors = [DoctorModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CreateGradienBackGround(view: self.view)
        myTableView.frame.origin.y = specialitiesCollection.frame.maxY
        separetorView.frame.origin.x = specialitiesCollection.frame.minX-1
        myTableView.frame.size.height = view.frame.maxY - myTableView.frame.minY
        callBt.layer.cornerRadius = callBt.frame.width/2
        directionBt.layer.cornerRadius = 5



        let classBundle = Bundle(for: DoctorTableCell.self)
        let nibProd = UINib(nibName:"DoctorTableCell", bundle:classBundle)
        self.myTableView.register(nibProd, forCellReuseIdentifier:"DoctorTableCell")

        if let clinic = ClinicModel.by(id: self.clinicId){
            self.updateWith(clinic: clinic)
        }


    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.showRMenu(false, animated:false)

        if ClinicModel.isRated(cId: self.clinicId) {
            if self.rateClinicBtn != nil {
                self.rateClinicBtn.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func SelectEspeciality(_ sender: AnyObject){
        let button = sender as! UIButton
        currentSelectedEspec = button.tag
        print("Especiliality pos: \(currentSelectedEspec)")
        //specialitiesCollection.reloadData()
        
        for cell in specialitiesCollection.visibleCells as! [SpecialityButtonCell] {
            if button != cell.specialityBt{
                cell.subButtonView.alpha = 0
            }
            else {
                cell.subButtonView.alpha = 1
            }
        }
    }
    
    @IBAction func GoBack(_ sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
    }

    private func updateWith(clinic: ClinicModel){

        self.nameClinicLb.text = clinic.full_name
        if let url = URL(string: clinic.profile_picture){
            self.avatarClinicIm.url = url
        }

        self.rateView.rating = clinic.rating

        self.addressLb.text = clinic.state + ", " + clinic.city + ", " + clinic.country

        self.doctors = clinic.getDoctors()
        self.myTableView.reloadData()



        self.specialitysNames = ["All"]
        for sp in clinic.specialties {
            if let spec = SpecialityModel.by(id: sp){
                self.specialitysNames.append(spec.name)
            }
        }
        if clinic.specialties.count == 1 { self.specialitysNames.remove(at: 0)}

        specialitiesCollection.reloadData()

        if clinic.phone_number.isEmpty { self.callBt.isHidden = true }

    }

    @IBAction func callBtnAction(_ sender: Any) {

        guard let clinic = ClinicModel.by(id: self.clinicId) else { return }

        var strPhoneNumber = clinic.phone_number!
        strPhoneNumber = strPhoneNumber.replacingOccurrences(of: " ", with: "")

        strPhoneNumber = strPhoneNumber.replacingOccurrences(of: "-", with: "")


        if let phoneCallURL:URL = URL(string: "tel:\(strPhoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                let alertController = UIAlertController(title: "ClinicsAndDoctors", message: "Are you sure you want to call \n\(clinic.phone_number!)?", preferredStyle: .alert)
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

       if segue.identifier == "toRating" {
            let vc:RatingVC = segue.destination as! RatingVC
            vc.clinicId = self.clinicId
        }

    }

}



//================================================
// MARK: - Collection Delegates
//================================================

extension ClinincDetailVC {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return specialitysNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = specialitiesCollection.dequeueReusableCell(withReuseIdentifier: "SpecialityButtonCell", for: indexPath) as! SpecialityButtonCell
        cell.specialityBt.setTitle(specialitysNames[indexPath.row], for: .normal)
        if currentSelectedEspec != indexPath.row {
            cell.subButtonView.alpha = 0
        }
        cell.specialityBt.tag = indexPath.row
        cell.specialityBt.addTarget(self, action: #selector(SelectEspeciality(_:)), for: .touchUpInside)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGSize = specialitysNames[indexPath.row].size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15.0)])

        return CGSize(width: size.width + 20, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}



//================================================
// MARK: - RMenu
//================================================
extension ClinincDetailVC {

    func showRMenu(_ show : Bool, animated: Bool = true){
        if show {
            self.view.bringSubview(toFront: self.rMenuView)
            rMenuView.isHidden = false
            self.rMenuDistance.constant = self.rMenuView.frame.width
            UIView.animate(withDuration: animated ? 0.3 : 0.01, animations: { [weak self] in
                self?.view.layoutIfNeeded()
            })
        }
        else{
            self.rMenuDistance.constant = 0
            UIView.animate(withDuration: animated ? 0.3 : 0.01, animations: {[weak self] in
                self?.view.layoutIfNeeded()
            }, completion: { _ in
                self.rMenuView.isHidden = true
            })
        }

    }

    @IBAction func rateMenuAction(_ sender: Any) {
        self.showRMenu(false)

        if UserModel.currentUser != nil {
            self.performSegue(withIdentifier: "toRating", sender: nil)
        }
        else{
            self.SwiftMessageAlert(layout: .cardView, theme: .info, title: "Clinics and Doctors", body: "Must be logged in first")

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! ViewController
            vc.futureVC = "RatingVC"
            vc.futureClinicId = self.clinicId

            navigationController?.pushViewController(vc,
                                                     animated: true)

        }
    }

    @IBAction func addFavMenuAction(_ sender: Any) {
        self.showRMenu(false)

        if UserModel.currentUser != nil {

            addToFav()
            
        }
        else{

            self.SwiftMessageAlert(layout: .cardView, theme: .info, title: "Clinics and Doctors", body: "Must be logged in first")

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {[weak self] in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! ViewController
                self?.navigationController?.pushViewController(vc, animated: true)
            })

        }
    }

    @IBAction func rateBtnAction(_ sender: Any) {
        showRMenu(rMenuView.isHidden)
    }


    func addToFav(){
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)

        ISClient.sharedInstance.addFavorite(clinicOrDoctorId: self.clinicId, objType: "clinic")
            .then { ok -> Void in
                if ok {
                    self.SwiftMessageAlert(layout: .cardView, theme: .success, title: "Clinics and Doctors", body: "Added to favorites")
                }

            }.always {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }.catch { error in
                if let e: LPError = error as? LPError { e.show() }
        }

    }


}



//================================================
// MARK: - TableView
//================================================

extension ClinincDetailVC {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.doctors.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorTableCell", for: indexPath) as! DoctorTableCell
        cell.updateWith(doctor: self.doctors[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DoctorDetailVC") as! DoctorDetailVC
        vc.rMenuBtnVisible = false
        vc.docId = self.doctors[indexPath.row].id

        navigationController?.pushViewController(vc,
                                                 animated: true)

    }

}
