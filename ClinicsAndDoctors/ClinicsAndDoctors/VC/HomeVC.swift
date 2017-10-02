//
//  HomeVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 30/09/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class HomeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MKMapViewDelegate,CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var especialitysCollection:UICollectionView!
    @IBOutlet weak var myMap:MKMapView!
    @IBOutlet weak var myTableView:UITableView!
    @IBOutlet weak var separetorView:UIView!
    var currentMilles = 100
    var locationManager = CLLocationManager()
    let especialitysArr = ["All","Cardiology","Dermatology","Emergency","Neurology"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        self.navigationController?.navigationBar.isHidden = false
        let smallLogoView = UIImageView.init(image: UIImage(named:"smallLogo"))
        self.navigationItem.titleView = smallLogoView
        myMap.alpha = 0
        myTableView.frame.origin.y = especialitysCollection.frame.maxY
        myMap.frame.origin.y = especialitysCollection.frame.maxY
        separetorView.frame.origin.x = especialitysCollection.frame.minX-1
        myTableView.frame.size.height = view.frame.maxY - myTableView.frame.minY
        myMap.frame.size.height = view.frame.maxY - myMap.frame.minY
        InitLocation()
        // Do any additional setup after loading the view.
    }
    /*
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }*/
    
    @IBAction func ShowMapOrListView(_sender:AnyObject){
        if myMap.alpha==0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.myMap.alpha = 1
                self.myMap.isUserInteractionEnabled = true
                self.myTableView.alpha = 0
                self.myTableView.isUserInteractionEnabled = false

                self.view.sendSubview(toBack: self.myTableView)
                self.view.bringSubview(toFront: self.myMap)
            })

            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "menuRigth")
        }
        else {
            UIView.animate(withDuration: 0.5, animations: {
                self.myMap.alpha = 0
                self.myMap.isUserInteractionEnabled = false
                self.myTableView.alpha = 1
                self.myTableView.isUserInteractionEnabled = true

                self.view.sendSubview(toBack: self.myMap)
                self.view.bringSubview(toFront: self.myTableView)
            })
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "icon_navbar_world")
        }
    }
    
    @IBAction func SliderMoved(_ slider: UISlider){
        currentMilles =  lroundf(slider.value)
        //print("Value of Slider: \(currentMilles)")
        
        //let header =  tableView.dequeueReusableCell(withIdentifier: "SliderMillesCell") as! SliderMillesCell
    }
    
    func InitLocation(){
        self.myMap.showsUserLocation = true
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        cell.especialityButton.setTitle(especialitysArr[indexPath.row], for: .normal)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row != 0{
            return CGSize(width: 100, height: 50)
        }
        else {
            return CGSize(width: 20, height: 50)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
