//
//  SliderMillesCell.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 02/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class SliderMillesCell: UITableViewCell {
    @IBOutlet weak var slider:UISlider!
    @IBOutlet weak var millesLb:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        

    }

    var kms:Float = 100.0 {
        didSet{
            self.slider.value = kms
            self.updateLabelValue()
        }
    }

    func updateLabelValue(){
        millesLb.text =  "\(lroundf(slider.value))"

    }

    @IBAction func SliderMovedInCell(_ slider: UISlider){
        self.kms = slider.value
    }
    


}
