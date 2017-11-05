//
//  FavoritesVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 08/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class FavoritesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var doctorsBt:UIButton!
    @IBOutlet weak var clinicsBt:UIButton!
    @IBOutlet weak var subView:UIView!
    @IBOutlet weak var myTableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.frame.origin.y = doctorsBt.frame.maxY
        myTableView.frame.size.height = view.frame.maxY - myTableView.frame.minY

        let classBundle = Bundle(for: DoctorTableCell.self)
        let nibProd = UINib(nibName:"DoctorTableCell", bundle:classBundle)
        self.myTableView.register(nibProd, forCellReuseIdentifier:"DoctorTableCell")



        if #available(iOS 11.0, *) {
            myTableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        myTableView.contentInset = UIEdgeInsetsMake(0,0,0,0);

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
        print("Show Doctors")
        UIView.animate(withDuration: 0.5) {
            self.subView.center.x = self.doctorsBt.center.x
            self.myTableView.reloadData()
        }
        
    }

    @IBAction func ShowClinics(_ sender: AnyObject){
        print("Show Clinics")
        UIView.animate(withDuration: 0.5) {
            self.subView.center.x = self.clinicsBt.center.x
            self.myTableView.reloadData()
        }
    }
    
    // MARK: - TableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.subView.center.x == self.clinicsBt.center.x {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClinicCell", for: indexPath) as! ClinicCell
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorTableCell", for: indexPath) as! DoctorTableCell

//            cell.updateWith(doctor: self.doctorInClinics[indexPath.row])
            return cell
        }
    }

}
