//
//  DoctorTableCell.swift
//  ClinicsAndDoctors
//
//  Created by Osmely Fernandez on 5/11/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import MapKit
import Cosmos

class DoctorTableCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: RoundedImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var clinicNameLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var ratingView: CosmosView!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    func updateWith(doctor: DoctorModel, mylocation:CLLocation?){

        if let url = URL(string: doctor.profile_picture){
            self.avatarImageView.url = url
        }
        self.nameLbl.text = doctor.full_name

        self.clinicNameLbl.text = ""
        self.distanceLbl.text = ""
        self.ratingView.rating = doctor.rating

        if let clinic = ClinicModel.by(id: doctor.idClinic) {
            self.clinicNameLbl.text = clinic.full_name

            if let loc = mylocation {
                let clinicCoord = CLLocation(latitude: clinic.latitude, longitude: clinic.longitude)
                let distance = loc.distance(from: clinicCoord) / 1000.0
                self.distanceLbl.text = "\(distance.rounded(toPlaces: 2)) Km Away"
            }
        }


    }
    
}
