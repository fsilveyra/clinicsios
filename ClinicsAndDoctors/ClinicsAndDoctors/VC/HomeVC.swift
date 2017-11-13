//
//  HomeVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 30/09/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import CoreLocation
import SideMenu
import GoogleMaps
import NVActivityIndicatorView
import Alamofire
import AlamofireImage
import PromiseKit
import YYWebImage
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON


class HomeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GMSMapViewDelegate,CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISideMenuNavigationControllerDelegate {
    
    @IBOutlet weak var especialitysCollection:UICollectionView!
    @IBOutlet weak var myMap:GMSMapView!
    @IBOutlet weak var myTableView:UITableView!
    @IBOutlet weak var locationBt:UIButton!



    var myPoint: GMSMarker?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var locationManager = CLLocationManager()
    var specialitysNames = ["All"]
    var doctorInClinics = [DoctorModel]()
    var currentSelectedEspec = 0
    var viewSearch: UIView! = nil
    let loading = ActivityData()
    var infoView = CustomInfoVIew.instanceFromNib() as! CustomInfoVIew
    var tappedMarker = GMSMarker()
    var isFromSideMenuOrigin = false
    var polylines = [GMSPolyline]()


    override func viewDidLoad() {
        super.viewDidLoad()


        FBSDKLoginManager().logOut()

        
        self.title = ""

        self.navigationController?.navigationBar.isHidden = false
        let smallLogoView = UIImageView(image: UIImage(named:"smallLogo"))
        self.navigationItem.titleView = smallLogoView

        myMap.alpha = 1

        myTableView.alpha = 0
        myTableView.frame.origin.y = especialitysCollection.frame.maxY
        myMap.frame.origin.y = especialitysCollection.frame.maxY

        myTableView.frame.size.height = view.frame.maxY - myTableView.frame.minY
        myMap.frame.size.height = view.frame.maxY - myMap.frame.minY
        locationBt.layer.cornerRadius = 6

        let classBundle = Bundle(for: DoctorTableCell.self)
        let nibProd = UINib(nibName:"DoctorTableCell", bundle:classBundle)
        self.myTableView.register(nibProd, forCellReuseIdentifier:"DoctorTableCell")



        if #available(iOS 11.0, *) {
            myTableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        myTableView.contentInset = UIEdgeInsetsMake(0,0,0,0);


        configureSideMenu()

        initLocation()



    }

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.isHidden = false

        myTableView.frame.origin.y = especialitysCollection.frame.maxY
        myMap.frame.origin.y = especialitysCollection.frame.maxY
        myTableView.frame.size.height = view.frame.maxY - myTableView.frame.minY
        myMap.frame.size.height = view.frame.maxY - myMap.frame.minY
        self.infoView.removeFromSuperview()


        self.updateSpecialitySelection()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //reload!
        if !self.isFromSideMenuOrigin { self.loadData() }
        self.isFromSideMenuOrigin = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        myTableView.frame.origin.y = especialitysCollection.frame.maxY
        myMap.frame.origin.y = especialitysCollection.frame.maxY
        myTableView.frame.size.height = view.frame.maxY - myTableView.frame.minY
        myMap.frame.size.height = view.frame.maxY - myMap.frame.minY
        self.infoView.removeFromSuperview()

        self.isFromSideMenuOrigin = false
    }

    func configureSideMenu(){
        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenu") as? UISideMenuNavigationController
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuFadeStatusBar = false
        
    }
    
    @IBAction func ShowMapOrListView(_sender:AnyObject){
        self.infoView.removeFromSuperview()
        if myMap.alpha==0 {
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "menuRigth")

            UIView.animate(withDuration: 0.3, animations: {
                self.myMap.alpha = 1
                self.locationBt.alpha = 1
                self.myMap.isUserInteractionEnabled = true
                self.myTableView.alpha = 0
                self.myTableView.isUserInteractionEnabled = false
                self.view.sendSubview(toBack: self.myTableView)
                self.view.bringSubview(toFront: self.myMap)
                self.view.bringSubview(toFront: self.locationBt)
            })
        }
        else {
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "icon_navbar_world")

            UIView.animate(withDuration: 0.3, animations: {
                self.myMap.alpha = 0
                self.locationBt.alpha = 0
                self.myMap.isUserInteractionEnabled = false
                self.myTableView.alpha = 1
                self.myTableView.isUserInteractionEnabled = true
                self.view.sendSubview(toBack: self.myMap)
                self.view.sendSubview(toBack: self.locationBt)
                self.view.bringSubview(toFront: self.myTableView)
            })
        }
    }
    
    @IBAction func SliderMoved(_ slider: UISlider, event:UIEvent){
        if let touchEvent = event.allTouches?.first{
            switch touchEvent.phase{
            case .ended:
                let newval = lroundf(slider.value) * 1000
                if newval != UserModel.radiusLocationMeters {
                    UserModel.radiusLocationMeters = newval
                    print("Current Meters: \(UserModel.radiusLocationMeters)")

                    self.loadData()
                }
            default:
                break
            }
            
        }
    }

    func updateSpecialitySelection(){
        for cell in especialitysCollection.visibleCells as! [SpecialityButtonCell] {
            cell.selectedCell = (currentSelectedEspec == cell.specialityBt.tag)
        }
    }
    
    @IBAction func SelectEspeciality(_ sender: AnyObject){
        let button = sender as! UIButton
        currentSelectedEspec = button.tag
        print("Especiliality pos: \(currentSelectedEspec)")

        updateSpecialitySelection()

        self.loadData()
    }

    @IBAction func GoClinicDetails(_ sender: AnyObject){
        self.performSegue(withIdentifier: "goClinicDetails", sender: nil)
    }

    @IBAction func GoMap(_ sender: AnyObject){
        self.infoView.removeFromSuperview()
        self.drawPath()
    }

    func loadData(){
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)

        let spec = SpecialityModel.by(name: self.specialitysNames[self.currentSelectedEspec])

        self.loadSpecialitys().then {

            self.loadClinics(radius: UserModel.radiusLocationMeters, specialityId: spec?.id ?? nil)
            }.then {
                self.loadDoctors(specialityId:spec?.id ?? nil, clinicId: nil)
            }.then { _ -> Void in

                self.doctorInClinics = ClinicModel.allDoctorsInClinics()
                self.myTableView.reloadData()

            }.always {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }.catch { error in

                if let e: LPError = error as? LPError { e.show() }

                DispatchQueue.main.asyncAfter(
                    deadline: DispatchTime.now() + 1, execute: {

                        let alert = UIAlertController(title:"Clinics And Doctors", message: "Error loading from server. Please, try again.".localized, preferredStyle: .alert)

                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {[weak self] action in
                            self?.loadData()
                        }))

                        self.present(alert, animated: true, completion: nil)
                })
        }

    }


    func loadSpecialitys() -> Promise<Void> {
        SpecialityModel.specialities = [SpecialityModel]()

        return ISClient.sharedInstance.getSpecialtys()
            .then { specilityList -> Void in
                if specilityList.isEmpty {

                } else {
                    SpecialityModel.specialities = specilityList
                    self.specialitysNames = ["All"]
                    for sp in SpecialityModel.specialities{
                        self.specialitysNames.append(sp.name)
                    }

                    self.especialitysCollection.reloadData()
                    //self.updateSpecialitySelection()
                }
        }
    }
    
    func loadClinics(radius: Int, specialityId: String? = nil) -> Promise<Void>{
        let location = locationManager.location ?? CLLocation(latitude: 0, longitude: 0)
        return ISClient.sharedInstance.getClinics(latitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude,
                                                  radius: radius,
                                                  specialty_id: specialityId)
            .then { clist -> Void in
                ClinicModel.clinics = clist
                self.ShowClinicsMarkerInMap()

        }
    }

    func loadDoctors(specialityId: String?, clinicId:String?) -> Promise<Void>{
        return ISClient.sharedInstance.getDoctors(specialty_id: specialityId, clinic_id:clinicId)
            .then { doctors -> Void in
                DoctorModel.doctors = doctors
        }
    }

}




//==========================================================
// MARK: - Google Maps
//==========================================================

extension HomeVC {

    func initLocation(){
        self.myMap.isMyLocationEnabled = false
        self.myMap.settings.compassButton = true
        self.myMap.settings.myLocationButton = false

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self

        //Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }

        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }

    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if marker != self.myPoint {
            return UIView()
        }
        return nil
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker != self.myPoint {
            tappedMarker = marker
            self.infoView.removeFromSuperview()


            guard let clinic = ClinicModel.by(id: marker.userData as! String) else { return false }

            self.infoView.mylocation = self.locationManager.location
            self.infoView.updateWith(clinic: clinic)

            self.infoView.infoBt.addTarget(self, action: #selector(GoClinicDetails(_:)), for: .touchUpInside)
            self.infoView.callBt.addTarget(self, action: #selector(GoMap(_:)), for: .touchUpInside)

            if let image = (marker.iconView as! UIImageView).image {
                self.infoView.imageView.image = image
            }

            self.infoView.contentView.layer.cornerRadius = 10
            self.infoView.internalContentView.layer.cornerRadius = 10

            var markPos = myMap.projection.point(for: marker.position)
            markPos.x -= 28
            markPos.y += (self.infoView.frame.height / 2 - 3)

            self.infoView.frame.origin = markPos
            self.view.addSubview(self.infoView)
            self.view.bringSubview(toFront: especialitysCollection)
            self.view.bringSubview(toFront: locationBt)


            let point = marker.position
            var pixelpoint = myMap.projection.point(for: point)
            pixelpoint.x += (self.infoView.frame.width / 2) - 28
            let newpoint = myMap.projection.coordinate(for: pixelpoint)


            let camera = GMSCameraPosition.camera(withLatitude: newpoint.latitude, longitude: newpoint.longitude, zoom: myMap.camera.zoom)
            myMap.animate(to: camera)

            return true

        }
        return false
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        var markPos = myMap.projection.point(for: tappedMarker.position)
        markPos.y += (self.infoView.frame.height / 2 - 3)
        markPos.x -= 28

        self.infoView.frame.origin = markPos
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.infoView.removeFromSuperview()
    }

    // MARK: - Location Manager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let eventDate = location?.timestamp
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        let currentLocation = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)

        UserModel.mylocation = location

        let howRecent = eventDate?.timeIntervalSinceNow
        if fabs(howRecent!) < 15 {

            if myPoint == nil{
                myPoint = GMSMarker(position: currentLocation)
                myPoint?.title = "My Location"

                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
                imageView.layer.cornerRadius = imageView.frame.width/2
                imageView.clipsToBounds = true
                imageView.image = UIImage(named: "icon_location")
                myPoint?.iconView = imageView
                myPoint?.map = myMap

                let camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: 14.0)
                myMap.animate(to: camera)

            }
            else {
                myPoint?.position = currentLocation
            }
        }
    }

    func ShowClinicsMarkerInMap(){
        myMap.clear()
        for clinic in ClinicModel.clinics {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
            imageView.layer.cornerRadius = imageView.frame.width/2
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.backgroundColor = .white
            imageView.yy_setImage(with: URL(string: clinic.profile_picture)!, placeholder: #imageLiteral(resourceName: "pinInfinix"), options: .setImageWithFadeAnimation, completion: { (image, _, _, _, error) in
            })

            let pinClinic = GMSMarker(position: CLLocationCoordinate2D(latitude: clinic.latitude,longitude: clinic.longitude))

            pinClinic.iconView = imageView
            pinClinic.title = clinic.full_name
            pinClinic.map = self.myMap
            pinClinic.userData = clinic.id

        }
    }

    @IBAction func ShowMyLocation(_ sende: AnyObject){
        if locationManager.location != nil {
            if myPoint==nil{
                myPoint = GMSMarker(position: (locationManager.location?.coordinate)!)
                myPoint?.title = "My Location"
                myPoint?.icon = #imageLiteral(resourceName: "icon_location")
                myPoint?.map = myMap
            }
            else {
                myPoint?.position = (locationManager.location?.coordinate)!
                myPoint?.icon = #imageLiteral(resourceName: "icon_location")
                myPoint?.map = myMap
            }
            let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 14.0)
            myMap.animate(to: camera)
        }
        else {
            print("location no update")
        }

    }

}



//==========================================================
// MARK: - TableView Delegates
//==========================================================

extension HomeVC {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.doctorInClinics.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SliderMillesCell") as! SliderMillesCell
        cell.kms = Float(UserModel.radiusLocationMeters / 1000)
        return cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorTableCell", for: indexPath) as! DoctorTableCell

        cell.updateWith(doctor: self.doctorInClinics[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        self.performSegue(withIdentifier: "toDoctorDetails", sender: self.doctorInClinics[indexPath.row].id)
    }

}


extension HomeVC {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "toDoctorDetails"{
            let docId = sender as! String
            let vc:DoctorDetailVC = segue.destination as! DoctorDetailVC
            vc.docId = docId
        }

        if segue.identifier == "goClinicDetails" {
            let vc:ClinincDetailVC = segue.destination as! ClinincDetailVC
            if let clinic = ClinicModel.by(id: tappedMarker.userData as! String){
                vc.clinicId = clinic.id
            }
        }

    }

}



//==========================================================
// MARK: - Collection Delegates
//==========================================================

extension HomeVC {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return specialitysNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = especialitysCollection.dequeueReusableCell(withReuseIdentifier: "SpecialityButtonCell", for: indexPath) as! SpecialityButtonCell
        cell.specialityBt.setTitle(specialitysNames[indexPath.row], for: .normal)
        
        cell.selectedCell = (currentSelectedEspec == indexPath.row)

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


//==========================================================
// MARK: - sideMenu Events
//==========================================================

extension HomeVC {

    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool){
        self.isFromSideMenuOrigin = true
    }

    func sideMenuDidAppear(menu: UISideMenuNavigationController, animated: Bool){
        self.isFromSideMenuOrigin = true
    }

    func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool){
        self.isFromSideMenuOrigin = true
    }

    func sideMenuDidDisappear(menu: UISideMenuNavigationController, animated: Bool){
        
    }
}


extension HomeVC {

    func drawPath() {

        for pl in polylines {
            pl.map = nil
        }
        polylines = [GMSPolyline]()


        guard let currentLocation = UserModel.mylocation else { return }
        guard let clinic = ClinicModel.by(id: tappedMarker.userData as! String) else { return }
        let finalLoc:CLLocation = CLLocation(latitude: clinic.latitude, longitude: clinic.longitude)
        guard let key = UserDefaults.standard.string(forKey: "google_key") else { return }

        let origin = "\(currentLocation.coordinate.latitude ),\(currentLocation.coordinate.longitude)"
        let destination = "\(finalLoc.coordinate.latitude ),\(finalLoc.coordinate.longitude)"

        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(key)"

        Alamofire.request(url).responseJSON {[weak self] response in
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue

            for route in routes {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.map = self?.myMap
                self?.polylines.append(polyline)
            }
        }
    }

}
