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
    @IBOutlet weak var addressLb:UILabel!
    @IBOutlet weak var rateView: CosmosView!
    @IBOutlet weak var specialitiesCollection:UICollectionView!
    @IBOutlet weak var myTableView:UITableView!
    @IBOutlet weak var addFavoriteBt: RoundedButton!
    @IBOutlet weak var phoneBt: RoundedButton!
    @IBOutlet weak var seeReviewsBtn: UIButton!
    @IBOutlet weak var defaultView: UIView!
    @IBOutlet weak var searchBtn: UIButton!

    var searchView : SearchView? = nil
    var topSearch:CGFloat = 0

    var specialitysNames = ["All"]
    var currentSelectedEspec = 0

    var clinicId = ""
    var doctors = [DoctorModel]()

    func translateStaticInterface(){
        seeReviewsBtn.setTitle("Reviews".localized, for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        translateStaticInterface()
        CreateGradienBackGround(view: self.view)
        myTableView.frame.origin.y = specialitiesCollection.frame.maxY
        myTableView.frame.size.height = view.frame.maxY - myTableView.frame.minY


        let classBundle = Bundle(for: DoctorTableCell.self)
        let nibProd = UINib(nibName:"DoctorTableCell", bundle:classBundle)
        self.myTableView.register(nibProd, forCellReuseIdentifier:"DoctorTableCell")


        self.addFavoriteBt.setImage(UIImage(named:"ic_fav_off"), for: .normal)
        self.addFavoriteBt.setImage(UIImage(named:"ic_favorite_profile"), for: .selected)

        self.seeReviewsBtn.underlined()


        configureSearch()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.defaultView.frame = self.myTableView.frame
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false

        if let clinic = ClinicModel.by(id: self.clinicId){
            self.updateWith(clinic: clinic)
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


        self.myTableView.isHidden = !(self.doctors.count > 0)
        self.defaultView.isHidden = (self.doctors.count > 0)


        self.specialitysNames = ["All"]
        for sp in clinic.specialties {
            if let spec = SpecialityModel.by(id: sp){
                self.specialitysNames.append(spec.name)
            }
        }
        if clinic.specialties.count == 1 { self.specialitysNames.remove(at: 0)}

        specialitiesCollection.reloadData()

        self.phoneBt.isHidden = clinic.phone_number.isEmpty
        self.addFavoriteBt.isSelected = UserModel.currentUser != nil && clinic.is_favorite

    }

    @IBAction func callBtnAction(_ sender: Any) {

        guard let clinic = ClinicModel.by(id: self.clinicId) else { return }

        var strPhoneNumber = clinic.phone_number!
        strPhoneNumber = strPhoneNumber.replacingOccurrences(of: " ", with: "")

        strPhoneNumber = strPhoneNumber.replacingOccurrences(of: "-", with: "")


        if let phoneCallURL:URL = URL(string: "tel:\(strPhoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                let alertController = UIAlertController(title: "ClinicsAndDoctors", message: "Are you sure you want to call".localized + " \n\(clinic.phone_number!)?", preferredStyle: .alert)
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


    @IBAction func openMapAction(_ sender: Any) {

        guard let clinic = ClinicModel.by(id: self.clinicId) else { return }

        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(clinic.latitude, clinic.longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = clinic.full_name
        mapItem.openInMaps(launchOptions: options)
    }


    @IBAction func shareAction(_ sender: Any) {
        
        guard let clinic = ClinicModel.by(id: self.clinicId) else { return }

        var text = clinic.full_name ?? ""
        if !clinic.address.isEmpty {
            text = text + " - " + clinic.address
        }

        if !clinic.phone_number.isEmpty {
            text = text + " - " + clinic.phone_number
        }

        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view


        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook, UIActivityType.postToTwitter ]

        self.present(activityViewController, animated: true, completion: nil)

    }


    @IBAction func rateMenuAction(_ sender: Any) {


        if UserModel.currentUser != nil {
            self.performSegue(withIdentifier: "toRating", sender: nil)
        }
        else{
            self.SwiftMessageAlert(layout: .cardView, theme: .info, title: "ClinicsAndDoctors", body: "Must be logged in first".localized)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {[weak self] in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! ViewController
                vc.futureVC = "RatingVC"
                vc.futureClinicId = self?.clinicId

                self?.navigationController?.pushViewController(vc,
                                                               animated: true)
            })

        }
    }

    @IBAction func addFavMenuAction(_ sender: Any) {

        if UserModel.currentUser != nil {
            addOrRemoveFav()
        }
        else{

            self.SwiftMessageAlert(layout: .cardView, theme: .info, title: "ClinicsAndDoctors", body: "Must be logged in first".localized)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {[weak self] in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! ViewController
                self?.navigationController?.pushViewController(vc, animated: true)
            })

        }
    }


    func addOrRemoveFav(){

        guard let clinic = ClinicModel.by(id: self.clinicId) else { return }

        NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)

        if clinic.is_favorite {

            ISClient.sharedInstance.removeFavorite(clinicOrDoctorId: self.clinicId, objType: "clinic")
                .then { ok -> Void in

                    if ok {
                        self.SwiftMessageAlert(layout: .cardView, theme: .success, title: "ClinicsAndDoctors", body: "Removed from favorites".localized)

                        ClinicModel.by(id: self.clinicId)?.is_favorite = false
                        self.updateWith(clinic: ClinicModel.by(id: self.clinicId)!)
                    }


                }.always {
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                }.catch { error in
                    if let e: LPError = error as? LPError { e.show() }
            }

        }else{

            ISClient.sharedInstance.addFavorite(clinicOrDoctorId: self.clinicId, objType: "clinic")
                .then { ok -> Void in

                    if ok {
                        self.SwiftMessageAlert(layout: .cardView, theme: .success, title: "ClinicsAndDoctors", body: "Added to favorites".localized)

                        ClinicModel.by(id: self.clinicId)?.is_favorite = true
                        self.updateWith(clinic: ClinicModel.by(id: self.clinicId)!)
                    }

                }.always {
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                }.catch { error in
                    if let e: LPError = error as? LPError { e.show() }
            }

        }

    }

}

// ==========================================
// MARK: - Navigation
// ==========================================

extension ClinincDetailVC {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toReviews" {
            let vc:ReviewsVC = segue.destination as! ReviewsVC
            vc.clinicId = self.clinicId

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




//==========================================================
// MARK: - Search
//==========================================================

extension ClinincDetailVC {

    func configureSearch(){
        self.topSearch = self.searchBtn.frame.origin.y
        showSearchPanel(false, animated:false)

        self.searchView?.onClose = {[weak self] in
            self?.showSearchPanel(false)
            //self?.loadData()
        }

        self.searchView?.onSelectItem = {[weak self] (itemId, itemType) in

            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            if itemType == "doctor" {
                let vc = storyboard.instantiateViewController(withIdentifier: "DoctorDetailVC") as! DoctorDetailVC
                vc.docId = itemId
                self?.navigationController?.pushViewController(vc, animated: true)
            }else{
                let vc = storyboard.instantiateViewController(withIdentifier: "ClinincDetailVC") as! ClinincDetailVC
                vc.clinicId = itemId
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }

    }

    func showSearchPanel(_ show:Bool, animated:Bool = true){

        let size = self.view.frame.size
        let topSize = CGSize(width:size.width, height: size.height - topSearch)
        let topFrame = CGRect(x:0, y:topSearch, width:topSize.width, height: topSize.height)
        let bottonFrame = CGRect(x:0, y:size.height, width:topSize.width, height: topSize.height)

        if self.searchView == nil {
            self.searchView = SearchView(frame: bottonFrame)
            self.searchView?.clinicId = self.clinicId
            self.view.addSubview(self.searchView!)
        }

        guard let sview = self.searchView else {return}

        self.view.bringSubview(toFront: sview)

        if show {

            if !sview.isHidden {return}

            sview.isHidden = false
            sview.frame = bottonFrame
            sview.setNeedsLayout()
            UIView.animate(withDuration: animated ? 0.2 : 0.01, delay: 0, options: [.curveEaseOut], animations: {
                sview.frame = topFrame
                sview.setNeedsLayout()
            }, completion: { completed in
                sview.textField.becomeFirstResponder()

            })

        }else{

            if sview.isHidden {return}
            sview.frame = topFrame
            sview.setNeedsLayout()

            UIView.animate(withDuration: animated ? 0.2 : 0.01, delay: 0, options: [.curveEaseIn], animations: {
                sview.frame = bottonFrame
                sview.setNeedsLayout()
            }, completion: { completed in
                sview.isHidden = true
            })

            self.view.endEditing(true)

        }

    }



    @IBAction func searchAction(_ sender:UIButton){
        showSearchPanel(self.searchView!.isHidden)
    }

}

