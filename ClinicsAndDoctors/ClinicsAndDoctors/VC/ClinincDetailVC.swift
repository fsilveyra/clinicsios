//
//  ClinincDetailVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 09/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class ClinincDetailVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var avatarClinicIm:UIImageView!
    @IBOutlet weak var nameClinicLb:UILabel!
    @IBOutlet weak var centerLb:UILabel!
    @IBOutlet weak var addressLb:UILabel!
    @IBOutlet weak var directionBt:UIButton!
    @IBOutlet weak var callBt:UIButton!
    @IBOutlet weak var start1:UIButton!
    @IBOutlet weak var start2:UIButton!
    @IBOutlet weak var start3:UIButton!
    @IBOutlet weak var start4:UIButton!
    @IBOutlet weak var start5:UIButton!

    @IBOutlet weak var specialitiesCollection:UICollectionView!
    @IBOutlet weak var myTableView:UITableView!
    @IBOutlet weak var separetorView:UIView!

    var specialitysNames = ["All"]
    var currentSelectedEspec = 0

    
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



        self.specialitysNames = ["All"]
        for sp in SpecialityModel.specialities{
            self.specialitysNames.append(sp.name)
        }

        specialitiesCollection.reloadData()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
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
    
    
    // MARK: - TableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorTableCell", for: indexPath) as! DoctorTableCell

        //cell.updateWith(doctor: self.doctorInClinics[indexPath.row])
        return cell
    }
    
    // MARK: - Collection Delegates
    
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


    @IBAction func rateBtnAction(_ sender: Any) {
        if UserModel.currentUser != nil {
            self.performSegue(withIdentifier: "toRating", sender: nil)
        }
        else{

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! ViewController
            vc.futureVC = "RatingVC"
            
            navigationController?.pushViewController(vc,
                                                     animated: true)

        }
    }




}
