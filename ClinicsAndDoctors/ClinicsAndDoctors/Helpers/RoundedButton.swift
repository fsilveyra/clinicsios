//
//  RoundedButton.swift
//  PezoParent
//
//  Created by Osmely Fernandez on 30/6/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {


    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable var borderW: CGFloat = 0 {
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

    }

}
