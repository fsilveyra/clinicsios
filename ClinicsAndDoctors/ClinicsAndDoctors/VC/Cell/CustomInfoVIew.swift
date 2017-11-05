//
//  CustomInfoVIew.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 05/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import MapKit

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
    var mylocation:CLLocation?

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomInfoVIewX", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }


    func updateWith(clinic: ClinicModel){
        self.clinicNameLb.text = clinic.full_name

        self.numberDoctorsLb.text = "\(clinic.getDoctorNumber()) doctors"

        if let loc = self.mylocation {
            let clinicCoord = CLLocation(latitude: clinic.latitude, longitude: clinic.longitude)
            let distance = loc.distance(from: clinicCoord) / 1000.0
            self.millLb.text = "\(distance.rounded(toPlaces: 2)) Km Away"
        }else{
            self.millLb.text = ""
        }


    }

}
