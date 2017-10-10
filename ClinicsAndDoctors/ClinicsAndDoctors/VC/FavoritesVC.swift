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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorCellInFavorite", for: indexPath) as! DoctorCell
            return cell
        }
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
