//
//  ClinicTableCell.swift
//  ClinicsAndDoctors
//
//  Created by Osmely Fernandez on 5/11/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import MapKit

class ClinicTableCell: UITableViewCell {

    @IBOutlet weak var avatarIcon:RoundedImageView!
    @IBOutlet weak var clinicNameLb:UILabel!
    @IBOutlet weak var millesLb:UILabel!
    @IBOutlet weak var markImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateWith(clinic: ClinicModel, location: CLLocation?){

        if let url = URL(string: clinic.profile_picture){
            self.avatarIcon.url = url
        }

        self.clinicNameLb.text = clinic.full_name

        self.millesLb.text = ""
        self.markImage.isHidden = true
        if let loc = location{
            self.markImage.isHidden = false

            let clinicCoord = CLLocation(latitude: clinic.latitude, longitude: clinic.longitude)
            let distance = loc.distance(from: clinicCoord) / 1000.0
            self.millesLb.text = "\(distance.rounded(toPlaces: 2)) Km Away"
        }


    }
}
