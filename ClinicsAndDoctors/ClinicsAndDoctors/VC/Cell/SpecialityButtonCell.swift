//
//  SpecialityButtonCell.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 01/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class SpecialityButtonCell: UICollectionViewCell {
    @IBOutlet weak var specialityBt:UIButton!
    @IBOutlet weak var subButtonView:UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var selectedCell : Bool = false {
        didSet{
            subButtonView.alpha = selectedCell ? 1 : 0
        }
    }
}
