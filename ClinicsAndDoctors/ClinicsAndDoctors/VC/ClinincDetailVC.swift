//
//  ClinincDetailVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 09/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class ClinincDetailVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
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
    @IBOutlet weak var searchBt:UIButton!
    @IBOutlet weak var especialitysCollection:UICollectionView!
    @IBOutlet weak var myTableView:UITableView!
    @IBOutlet weak var separetorView:UIView!

    let especialitysArr = ["All","Cardiology","Dermatology","Emergency","Neurology"]
    var currentSelectedEspec = 0
    var viewSearch: UIView! = nil
    var searchController:UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CreateGradienBackGround(view: self.view)
        myTableView.frame.origin.y = especialitysCollection.frame.maxY
        separetorView.frame.origin.x = especialitysCollection.frame.minX-1
        myTableView.frame.size.height = view.frame.maxY - myTableView.frame.minY
        callBt.layer.cornerRadius = callBt.frame.width/2
        directionBt.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
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
    
    @IBAction func GoBack(_ sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
    }
    
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
    
    // MARK: - Search Controller Delegates
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
        
        // You could also change the position, frame etc of the searchBar
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        print("result")
    }
    
    // MARK: - TableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
