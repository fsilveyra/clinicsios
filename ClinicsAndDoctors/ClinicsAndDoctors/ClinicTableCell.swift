//
//  ClinicTableCell.swift
//  ClinicsAndDoctors
//
//  Created by Osmely Fernandez on 5/11/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import MapKit
import Cosmos

class ClinicTableCell: UITableViewCell {

    @IBOutlet weak var avatarIcon:RoundedImageView!
    @IBOutlet weak var clinicNameLb:UILabel!
    @IBOutlet weak var millesLb:UILabel!
    @IBOutlet weak var markImage: UIImageView!
    @IBOutlet weak var ratingView: CosmosView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateWith(clinic: ClinicModel){

        if let url = URL(string: clinic.profile_picture){
            self.avatarIcon.url = url
        }

        self.clinicNameLb.text = clinic.full_name
        self.ratingView.rating = clinic.rating
        self.millesLb.text = ""
        self.markImage.isHidden = true
        if let loc = UserModel.mylocation {
            self.markImage.isHidden = false

            let clinicCoord = CLLocation(latitude: clinic.latitude, longitude: clinic.longitude)
            let distance = loc.distance(from: clinicCoord) / 1000.0
            self.millesLb.text = "\(distance.rounded(toPlaces: 2)) " + "Km Away".localized
        }


    }
}
