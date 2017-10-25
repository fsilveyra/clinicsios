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


class HomeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GMSMapViewDelegate,CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var especialitysCollection:UICollectionView!
    @IBOutlet weak var myMap:GMSMapView!
    @IBOutlet weak var myTableView:UITableView!
    //@IBOutlet weak var separetorView:UIView!
    @IBOutlet weak var locationBt:UIButton!
    //@IBOutlet weak var searchBt:UIButton!

    var myPoint: GMSMarker? {
        didSet{
            ShowClinicsMarkerInMap()
        }
    }
    //var searchController:UISearchController!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentMilles = 100
    var locationManager = CLLocationManager()
    var especialitysArr = ["All"]
    var specialitysList : [Speciality] = []
    var currentSelectedEspec = 0
    var viewSearch: UIView! = nil
    let loading = ActivityData()
    var infoView = CustomInfoVIew.instanceFromNib() as! CustomInfoVIew
    var tappedMarker = GMSMarker()
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        self.navigationController?.navigationBar.isHidden = false
        let smallLogoView = UIImageView.init(image: UIImage(named:"smallLogo"))
        self.navigationItem.titleView = smallLogoView
        myMap.alpha = 1
        myTableView.alpha = 0
        myTableView.frame.origin.y = especialitysCollection.frame.maxY
        myMap.frame.origin.y = especialitysCollection.frame.maxY
        //separetorView.frame.origin.x = especialitysCollection.frame.minX-1
        myTableView.frame.size.height = view.frame.maxY - myTableView.frame.minY
        myMap.frame.size.height = view.frame.maxY - myMap.frame.minY
        locationBt.layer.cornerRadius = 6
        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenu") as? UISideMenuNavigationController
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuFadeStatusBar = false
        InitLocation()
        
        self.LoadSpecialitys()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myTableView.frame.origin.y = especialitysCollection.frame.maxY
        myMap.frame.origin.y = especialitysCollection.frame.maxY
        //separetorView.frame.origin.x = especialitysCollection.frame.minX-1
        myTableView.frame.size.height = view.frame.maxY - myTableView.frame.minY
        myMap.frame.size.height = view.frame.maxY - myMap.frame.minY
        self.infoView.removeFromSuperview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        myTableView.frame.origin.y = especialitysCollection.frame.maxY
        myMap.frame.origin.y = especialitysCollection.frame.maxY
        //separetorView.frame.origin.x = especialitysCollection.frame.minX-1
        myTableView.frame.size.height = view.frame.maxY - myTableView.frame.minY
        myMap.frame.size.height = view.frame.maxY - myMap.frame.minY
        self.infoView.removeFromSuperview()
    }
    
    // MARK: - @IBActions
    /*
    @IBAction func ShowSearchBar(){
        searchController = UISearchController.init(searchResultsController: nil)
        searchController.searchBar.barTintColor = UIColor(red: 23.0/255, green: 55.0/255.0, blue: 78.0/255.0, alpha: 1)
        //searchController.searchBar.alpha = 1
        //searchController.searchBar.isTranslucent = false
        searchController.searchBar.placeholder = "Search doctors or clinics"
        
        searchController.searchBar.tintColor = .white
        searchController.searchResultsUpdater = self
        
        //self.definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.delegate = self
        searchController.delegate = self
        
        //searchController.searchBar.cance
        self.viewSearch = UIView(frame: CGRect.init(x: 0, y: searchBt.frame.origin.y, width: self.view.bounds.width, height: searchController.searchBar.frame.height))
        self.viewSearch.backgroundColor =  UIColor(red: 23.0/255, green: 55.0/255.0, blue: 78.0/255.0, alpha: 1)
        //self.viewSearch.clipsToBounds = true
        //searchController.searchBar.frame.size.height = viewSearch.frame.height
        //searchController.searchBar.frame.size.width = viewSearch.frame.width
        
        viewSearch.addSubview(searchController.searchBar)
        self.view.addSubview(self.viewSearch)
        self.view.bringSubview(toFront: self.viewSearch)

        for cell in especialitysCollection.visibleCells as! [EspacialityButtonCell] {
                cell.subButtonView.alpha = 0
        }

        searchController.searchBar.becomeFirstResponder()
    }
    */
   
    
    @IBAction func ShowMapOrListView(_sender:AnyObject){
        self.infoView.removeFromSuperview()
        if myMap.alpha==0 {
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "menuRigth")

            UIView.animate(withDuration: 0.5, animations: {
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

            UIView.animate(withDuration: 0.5, animations: {
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
        
        for cell in especialitysCollection.visibleCells as! [EspacialityButtonCell] {
            if button != cell.especialityBt{
                cell.subButtonView.alpha = 0
            }
            else {
                cell.subButtonView.alpha = 1
            }
        }
    }
    
    @IBAction func ShowMyLocation(_ sende: AnyObject){
        if myPoint==nil{
            myPoint = GMSMarker.init(position: (locationManager.location?.coordinate)!)
            myPoint?.title = "My Location"
            myPoint?.icon = #imageLiteral(resourceName: "icon_location")
            myPoint?.map = myMap
        }
        else {
            myPoint?.position = (locationManager.location?.coordinate)!
        }
        let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 14.0)
        myMap.animate(to: camera)
    }
    
    @IBAction func GoClinicDetails(_ sender: AnyObject){
        print("goClinicDetails")
        self.performSegue(withIdentifier: "goClinicDetails", sender: nil)
    }
    
    // MARK: - Initialization
    
    func InitLocation(){
        self.myMap.isMyLocationEnabled = false
        self.myMap.settings.compassButton = true
        self.myMap.settings.myLocationButton = false
        //self.myMap.lo
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

    func generateRandomMarker() -> GMSMarker{

        let deltax = Double(arc4random()) / Double(UInt32.max)
        let valx = ((deltax * 20.0) - 10.0) * 0.001
        let deltay = Double(arc4random()) / Double(UInt32.max)
        let valy = ((deltay * 20.0) - 10.0) * 0.001

        let p = GMSMarker.init(position: CLLocationCoordinate2D.init(latitude: (myPoint?.position.latitude)! + valx,
                                                                             longitude: (myPoint?.position.longitude)! + valy))
        return p
    }

    func ShowClinicsMarkerInMap(){
        let pinClinic = generateRandomMarker()
        pinClinic.title = "River Clinic"
        pinClinic.icon = #imageLiteral(resourceName: "pin_clinic")
        pinClinic.map = myMap
        
        let pinClinic1 = generateRandomMarker()
        pinClinic1.title = "Infinix Clinic"
        pinClinic1.icon = #imageLiteral(resourceName: "pinInfinix")
        pinClinic1.map = myMap
        
        let pinClinic2 = generateRandomMarker()
        pinClinic2.title = "Infi Health Clinic"
        pinClinic2.icon = #imageLiteral(resourceName: "pinInfiHealth")
        pinClinic2.map = myMap
    }
    
    func LoadClinics (forLocation : CLLocation){
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)
        ISClient.sharedInstance.GetClinics(latitude: forLocation.coordinate.latitude, longitude: forLocation.coordinate.longitude, radius: currentMilles, user_id: User.sharedInstance.id) { (success, error) in
            if success! {
                print("\(ISClient.sharedInstance.clinicsList.count) Clinics Loaded")
                //Function to show mark in Maps
                //Reload Data in Doctors List Table View
            }
            else {
                print("Error Loading Clinics")
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: error! )
            }
        }
    }
    
    func LoadSpecialitys(){
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)
        ISClient.sharedInstance.GetSpecialtys { (specilityList, error) in
            if (specilityList?.isEmpty)! {
                print("Error Loading Specilitys")
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: error! )
            }
            else {
                 NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                for speciality in specilityList!{
                    self.especialitysArr.append(speciality.name)
                }
                //self.specialitysList = specilityList!
                self.especialitysCollection.reloadData()
            }
        }
    }
    
    // MARK: - Google Maps Delegates
    
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
            //self.view.bringSubview(toFront: searchBt)
            //self.view.bringSubview(toFront: separetorView)
            self.view.bringSubview(toFront: locationBt)
        }
        return false
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.infoView.center = myMap.projection.point(for: tappedMarker.position)
    }
    
    // take care of the close event
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.infoView.removeFromSuperview()
    }
    
    // MARK: - Location Manager Delegates

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let eventDate = location?.timestamp
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        let currentLocation = CLLocationCoordinate2D.init(latitude: latitude!, longitude: longitude!)
        let howRecent = eventDate?.timeIntervalSinceNow
        if fabs(howRecent!) < 15 {

            if myPoint==nil{
                myPoint = GMSMarker.init(position: currentLocation)
                myPoint?.title = "My Location"
                myPoint?.icon = #imageLiteral(resourceName: "icon_location")
                myPoint?.map = myMap

                let camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: 14.0)
                myMap.animate(to: camera)
            }
            else {
                myPoint?.position = currentLocation
            }
        }
    }
    
    // MARK: - TableView Delegates
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
    
    // MARK: - Collection Delegates
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return especialitysArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = especialitysCollection.dequeueReusableCell(withReuseIdentifier: "EspacialityButtonCell", for: indexPath) as! EspacialityButtonCell
        cell.especialityBt.setTitle(especialitysArr[indexPath.row], for: .normal)
        if currentSelectedEspec != indexPath.row {
            cell.subButtonView.alpha = 0
        }
        cell.especialityBt.tag = indexPath.row
        cell.especialityBt.addTarget(self, action: #selector(SelectEspeciality(_:)), for: .touchUpInside)
        
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
    
    // MARK: - Search Controller
    /*
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        self.viewSearch.removeFromSuperview()
        searchController = nil
        
        for cell in especialitysCollection.visibleCells as! [EspacialityButtonCell] {
            if currentSelectedEspec != cell.especialityBt.tag{
                cell.subButtonView.alpha = 0
            }
            else {
                cell.subButtonView.alpha = 1
            }
        }
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar){
            print("touch")
            if searchBar.text == "" {
                self.viewSearch.removeFromSuperview()
            }
        }
        // You could also change the position, frame etc of the searchBar
    }*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
