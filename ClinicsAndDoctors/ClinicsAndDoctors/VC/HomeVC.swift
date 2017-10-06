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

class HomeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GMSMapViewDelegate,CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        print("result")
    }
    
    @IBOutlet weak var especialitysCollection:UICollectionView!
    @IBOutlet weak var myMap:GMSMapView!
    @IBOutlet weak var myTableView:UITableView!
    @IBOutlet weak var separetorView:UIView!
    @IBOutlet weak var locationBt:UIButton!
    @IBOutlet weak var searchBt:UIButton!

    var myPoint: GMSMarker? {
        didSet{
            ShowClinicsMarkerInMap()
        }
    }
    var searchController:UISearchController!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentMilles = 100
    var locationManager = CLLocationManager()
    let especialitysArr = ["All","Cardiology","Dermatology","Emergency","Neurology"]
    var currentSelectedEspec = 0
    var viewSearch: UIView! = nil

    var infoView:CustomInfoVIew!
    
    
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
        separetorView.frame.origin.x = especialitysCollection.frame.minX-1
        myTableView.frame.size.height = view.frame.maxY - myTableView.frame.minY
        myMap.frame.size.height = view.frame.maxY - myMap.frame.minY
        locationBt.layer.cornerRadius = 6
        SideMenuManager.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenu") as? UISideMenuNavigationController
        SideMenuManager.menuPresentMode = .menuSlideIn
        SideMenuManager.menuFadeStatusBar = false
        InitLocation()

        // Do any additional setup after loading the view.
    }
    
    /*
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }*/
    // MARK: - @IBActions
    @IBAction func ShowSearchBar(){
        searchController = UISearchController.init(searchResultsController: nil)
        searchController.searchBar.barTintColor = UIColor(red: 23.0/255, green: 55.0/255.0, blue: 78.0/255.0, alpha: 1)
        //searchController.searchBar.barTintColor = .clear
        searchController.searchBar.tintColor = .white
        searchController.searchResultsUpdater = self
        self.definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.delegate = self
        searchController.delegate = self
        
        //searchController.searchBar.cance
        self.viewSearch = UIView(frame: CGRect.init(x: 0, y: searchBt.frame.origin.y, width: self.view.bounds.width, height: searchBt.frame.height))
        //searchController.searchBar.frame.size.height = viewSearch.frame.height
        //searchController.searchBar.frame.size.width = viewSearch.frame.width
        
        viewSearch.addSubview(searchController.searchBar)
        UIView.animate(withDuration: 0.5) {
            self.view.addSubview(self.viewSearch)
            self.view.bringSubview(toFront: self.viewSearch)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        self.viewSearch.removeFromSuperview()
        searchController = nil
        // You could also change the position, frame etc of the searchBar
    }
    
    @IBAction func ShowMapOrListView(_sender:AnyObject){
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
    
    @IBAction func SliderMoved(_ slider: UISlider){
        currentMilles =  lroundf(slider.value)
        //print("Value of Slider: \(currentMilles)")
        
        //let header =  tableView.dequeueReusableCell(withIdentifier: "SliderMillesCell") as! SliderMillesCell
        
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Google Maps Delegates
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if marker != self.myPoint {
            self.infoView = CustomInfoVIew.instanceFromNib() as! CustomInfoVIew
            self.infoView.contentView.layer.cornerRadius = 5
            self.infoView.clinicNameLb.text = marker.title
            //infoView.center = myMap.projection.point(for: marker.position)
            //self.infoView.transform = CGAffineTransform.init(translationX: infoView.frame.maxX, y: infoView.frame.maxY + infoView.frame.height * 1.5)
            /*Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
                let camera = mapView.projection.coordinate(for: CGPoint.init(x: self.infoView.transform.tx - self.infoView.frame.width/2 , y: self.infoView.transform.ty - self.infoView.frame.height / 2))
                let position = GMSCameraUpdate.setTarget(camera)
                mapView.animate(with: position)
               })*/
            return infoView
        }
        
        return nil
    }
    /*
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        return true
    }*/
    
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
            return CGSize(width: 100, height: 50)
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
