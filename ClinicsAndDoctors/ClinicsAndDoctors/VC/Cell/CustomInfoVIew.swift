//
//  CustomInfoVIew.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 05/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class CustomInfoVIew: UIView {
    @IBOutlet weak var clinicNameLb:UILabel!
    @IBOutlet weak var numberDoctorsLb:UILabel!
    @IBOutlet weak var millLb:UILabel!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var callBt:UIButton!
    @IBOutlet weak var infoBt:UIButton!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomInfoVIewX", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
