//
//  HomeVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 30/09/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
//import MapKit
import CoreLocation
import SideMenu
import GoogleMaps
import NVActivityIndicatorView
import Alamofire
import AlamofireImage
import PromiseKit
import YYWebImage

class HomeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GMSMapViewDelegate,CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var especialitysCollection:UICollectionView!
    @IBOutlet weak var myMap:GMSMapView!
    @IBOutlet weak var myTableView:UITableView!
    @IBOutlet weak var locationBt:UIButton!


    var myPoint: GMSMarker?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentMilles = 100
    var locationManager = CLLocationManager()
    var specialitysNames = ["All"]
    
    var clinicList = [Clinic]()
    var currentSelectedEspec = 0
    var viewSearch: UIView! = nil
    let loading = ActivityData()
    var infoView = CustomInfoVIew.instanceFromNib() as! CustomInfoVIew
    var tappedMarker = GMSMarker()


    override func viewDidLoad() {
        super.viewDidLoad()

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


        if #available(iOS 11.0, *) {
            myTableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        myTableView.contentInset = UIEdgeInsetsMake(0,0,0,0);



        configureSideMenu()

        initLocation()

        self.loadData()

    }

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }


    override func viewWillAppear(_ animated: Bool) {

        self.navigationController?.navigationBar.isHidden = false

        myTableView.frame.origin.y = especialitysCollection.frame.maxY
        myMap.frame.origin.y = especialitysCollection.frame.maxY
        myTableView.frame.size.height = view.frame.maxY - myTableView.frame.minY
        myMap.frame.size.height = view.frame.maxY - myMap.frame.minY
        self.infoView.removeFromSuperview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        myTableView.frame.origin.y = especialitysCollection.frame.maxY
        myMap.frame.origin.y = especialitysCollection.frame.maxY
        myTableView.frame.size.height = view.frame.maxY - myTableView.frame.minY
        myMap.frame.size.height = view.frame.maxY - myMap.frame.minY
        self.infoView.removeFromSuperview()
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
                currentMilles =  lroundf(slider.value)
                print("Current Milles: \(currentMilles)")
                //case .began:

                //case .moved:
                //
                //case .stationary:
                //
                //case .cancelled:
            //
            default:
                break
            }
            
        }
    }
    
    @IBAction func SelectEspeciality(_ sender: AnyObject){
        let button = sender as! UIButton
        currentSelectedEspec = button.tag
        print("Especiliality pos: \(currentSelectedEspec)")
        //especialitysCollection.reloadData()
        
        for cell in especialitysCollection.visibleCells as! [SpecialityButtonCell] {
            if button != cell.specialityBt{
                cell.subButtonView.alpha = 0
            }
            else {
                cell.subButtonView.alpha = 1
            }
        }
    }

    
    @IBAction func GoClinicDetails(_ sender: AnyObject){
        print("goClinicDetails")
        self.performSegue(withIdentifier: "goClinicDetails", sender: nil)
    }

    func loadData(){
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)

        self.LoadSpecialitys().then {
            self.LoadClinics()
            }.always {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }.catch { error in

                if let e: LPError = error as? LPError { e.show() }

                DispatchQueue.main.asyncAfter(
                    deadline: DispatchTime.now() + 1, execute: {

                        let alert = UIAlertController(title:"Clinics And Doctors", message: "Error loading from server. Please, try again.", preferredStyle: .alert)

                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {[weak self] action in
                            self?.loadData()
                        }))

                        self.present(alert, animated: true, completion: nil)
                })
        }

    }


    func LoadSpecialitys() -> Promise<Void> {
        Speciality.specialities = [Speciality]()

        return ISClient.sharedInstance.getSpecialtys()
            .then { specilityList -> Void in
                if specilityList.isEmpty {

                } else {
                    Speciality.specialities = specilityList
                    self.specialitysNames = ["All"]
                    for sp in Speciality.specialities{
                        self.specialitysNames.append(sp.name)
                    }

                    self.especialitysCollection.reloadData()
                }
        }
    }
    
    func LoadClinics(specialityId: String = "") -> Promise<Void>{

        return ISClient.sharedInstance.getClinics(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, radius: currentMilles*99999999, specialty_id: specialityId)
            .then { clist -> Void in
                self.clinicList = clist
                self.ShowClinicsMarkerInMap()
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
            /*self.infoView = CustomInfoVIew.instanceFromNib() as! CustomInfoVIew
             self.infoView.contentView.layer.cornerRadius = 5
             self.infoView.clinicNameLb.text = marker.title
             self.infoView.infoBt.addTarget(self, action: #selector(GoClinicDetails(_:)), for: .touchUpInside)
             self.infoView.isUserInteractionEnabled = true
             self.infoView.center = myMap.projection.point(for: marker.position)
             //self.infoView.transform = CGAffineTransform.init(translationX: infoView.frame.maxX, y: infoView.frame.maxY + infoView.frame.height * 1.5)
             /*Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
             let camera = mapView.projection.coordinate(for: CGPoint.init(x: self.infoView.transform.tx - self.infoView.frame.width/2 , y: self.infoView.transform.ty - self.infoView.frame.height / 2))
             let position = GMSCameraUpdate.setTarget(camera)
             mapView.animate(with: position)
             })*/
             return infoView*/
        }

        return nil
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker != self.myPoint {
            tappedMarker = marker
            self.infoView.removeFromSuperview()
            self.infoView.contentView.layer.cornerRadius = 5
            self.infoView.clinicNameLb.text = marker.title
            self.infoView.infoBt.addTarget(self, action: #selector(GoClinicDetails(_:)), for: .touchUpInside)
            self.infoView.center = myMap.projection.point(for: marker.position)
            self.view.addSubview(self.infoView)
            self.view.bringSubview(toFront: especialitysCollection)
            self.view.bringSubview(toFront: locationBt)
        }
        return false
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.infoView.center = myMap.projection.point(for: tappedMarker.position)
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
        let howRecent = eventDate?.timeIntervalSinceNow
        if fabs(howRecent!) < 15 {

            if myPoint==nil{
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
        for clinic in clinicList {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
            imageView.layer.cornerRadius = imageView.frame.width/2
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.yy_setImage(with: URL(string: clinic.profile_picture)!, placeholder: #imageLiteral(resourceName: "pinInfinix"), options: .setImageWithFadeAnimation, completion: { (image, _, _, _, error) in
            })

            let pinClinic = GMSMarker(position: CLLocationCoordinate2D(latitude: clinic.latitude,longitude: clinic.longitude))

            pinClinic.iconView = imageView
            pinClinic.title = clinic.full_name
            pinClinic.map = self.myMap
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
        return 10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SliderMillesCell") as! SliderMillesCell
        return cell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorCell", for: indexPath) as! DoctorCell
        return cell
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
        if currentSelectedEspec != indexPath.row {
            cell.subButtonView.alpha = 0
        }
        cell.specialityBt.tag = indexPath.row
        cell.specialityBt.addTarget(self, action: #selector(SelectEspeciality(_:)), for: .touchUpInside)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row != 0{
            return CGSize(width: 115, height: 50)
        }
        else {
            return CGSize(width: 40, height: 50)
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}


