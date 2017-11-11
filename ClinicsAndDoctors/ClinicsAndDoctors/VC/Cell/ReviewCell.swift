//
//  ReviewCell.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 08/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class ReviewCell: UITableViewCell {
    @IBOutlet weak var ReviewLb:UILabel!
    @IBOutlet weak var nameLb:UILabel!
    @IBOutlet weak var dateLb:UILabel!
    @IBOutlet weak var avatarIm:RoundedImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    func updateWithData(_ review : ReviewModel){
        self.ReviewLb.text = review.comment
        self.dateLb.text = review.created_date_time
        self.nameLb.text = review.user.full_name

        if let url = URL(string:review.user.profile_picture){
            self.avatarIm.url = url
        }

    }

}
