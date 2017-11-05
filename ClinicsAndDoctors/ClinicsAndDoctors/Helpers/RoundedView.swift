//
//  RoundedView.swift
//  PezoParent
//
//  Created by Osmely Fernandez on 3/7/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class RoundedView: UIView {


    @IBInspectable var cornerR: CGFloat = 10 {
        didSet{
            self.layer.cornerRadius = cornerR
        }
    }

    @IBInspectable var borderW: CGFloat = 1 {
        didSet{
            self.layer.borderWidth = borderW
        }
    }

    @IBInspectable var borderColor: String = "FFFFFF" {
        didSet{
            self.layer.borderColor = UIColor(hexString: borderColor).cgColor
        }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup(){
//        self.layer.cornerRadius = cornerR
//        self.layer.borderWidth = borderW
//        self.layer.borderColor = UIColor(white: 1.0, alpha: 0.7).cgColor
    }



    
}



