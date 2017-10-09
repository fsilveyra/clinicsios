//
//  ReviewsVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 08/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class ReviewsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var loadingIm:UIImageView!
    @IBOutlet weak var doctorAvatarIm:UIImageView!
    @IBOutlet weak var nameLb:UILabel!
    @IBOutlet weak var myTableView:UITableView!
    @IBOutlet weak var star1:UIButton!
    @IBOutlet weak var star2:UIButton!
    @IBOutlet weak var star3:UIButton!
    @IBOutlet weak var star4:UIButton!
    @IBOutlet weak var star5:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        CreateGradienBackGround(view: self.view)
        
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
    
    // MARK: - TableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerReview")
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        return cell
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
