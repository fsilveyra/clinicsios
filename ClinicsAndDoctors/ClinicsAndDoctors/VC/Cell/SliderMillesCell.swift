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
        
        // Initialization code
    }
    
    @IBAction func SliderMovedInCell(_ slider: UISlider){
        millesLb.text =  "\(lroundf(slider.value))"
        
        
        //let header =  tableView.dequeueReusableCell(withIdentifier: "SliderMillesCell") as! SliderMillesCell
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
