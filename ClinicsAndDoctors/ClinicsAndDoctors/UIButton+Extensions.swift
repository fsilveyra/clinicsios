//
//  UIButton+Extensions.swift
//  ClinicsAndDoctors
//
//  Created by Osmely Fernandez on 20/11/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import Foundation
import UIKit

extension UIButton{
    func underlined(){
        let attribRegBut : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue) : self.titleLabel?.font! ,
            NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue) : self.titleColor(for: .normal) ?? .white,
            NSAttributedStringKey(rawValue: NSAttributedStringKey.underlineStyle.rawValue) : NSUnderlineStyle.styleSingle.rawValue]
        let attributeString = NSMutableAttributedString(string: self.title(for: .normal)!.localized, attributes: attribRegBut)
        self.setAttributedTitle(attributeString, for: .normal)
    }
}


