//
//  CustomInfoVIew.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 05/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import MapKit
import Cosmos

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

class CustomInfoVIew: UIView {
    @IBOutlet weak var clinicNameLb:UILabel!
    @IBOutlet weak var numberDoctorsLb:UILabel!
    @IBOutlet weak var millLb:UILabel!
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var callBt:UIButton!
    @IBOutlet weak var infoBt:UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var internalContentView: RoundedView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var getDirectionsBtn: UIButton!


    var mylocation:CLLocation?

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomInfoVIewX", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }


    func updateWith(clinic: ClinicModel){
        self.callBt.setTitle("CALL".localized, for: .normal)
        self.infoBt.setTitle("INFO".localized, for: .normal)
        self.getDirectionsBtn.setTitle("Get Directions".localized, for: .normal)

        self.clinicNameLb.text = clinic.full_name
        self.ratingView.rating = clinic.rating
        self.numberDoctorsLb.text = "\(clinic.getDoctorNumber()) " + "doctors".localized

        if let loc = self.mylocation {
            let clinicCoord = CLLocation(latitude: clinic.latitude, longitude: clinic.longitude)
            let distance = loc.distance(from: clinicCoord) / 1000.0
            self.millLb.text = "\(distance.rounded(toPlaces: 2)) " + "Km Away".localized
        }else{
            self.millLb.text = ""
        }

        self.getDirectionsBtn.underlined()
    }

}
