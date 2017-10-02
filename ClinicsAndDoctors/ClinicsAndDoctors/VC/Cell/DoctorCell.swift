//
//  DoctorCell.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 01/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class DoctorCell: UITableViewCell {
    @IBOutlet weak var avatarIcon:UIImageView!
    @IBOutlet weak var doctorNameLb:UILabel!
    @IBOutlet weak var clinicNameLb:UILabel!
    @IBOutlet weak var millesLb:UILabel!
    @IBOutlet weak var start1:UIImageView!
    @IBOutlet weak var start2:UIImageView!
    @IBOutlet weak var start3:UIImageView!
    @IBOutlet weak var start4:UIImageView!
    @IBOutlet weak var start5:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarIcon.layer.cornerRadius = avatarIcon.frame.width/2
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
