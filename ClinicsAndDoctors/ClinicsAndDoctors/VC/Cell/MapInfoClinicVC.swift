//
//  MapInfoClinicVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 05/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class MapInfoClinicVC: UIViewController {
    @IBOutlet weak var clinicNameLb:UILabel!
    @IBOutlet weak var numberDoctorsLb:UILabel!
    @IBOutlet weak var millLb:UILabel!
    @IBOutlet weak var ratingLb:UILabel!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var callBt:UIButton!
    @IBOutlet weak var infoBt:UIButton!
    @IBOutlet weak var ratingIm:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
