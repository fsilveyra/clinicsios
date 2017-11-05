//
//  UIViewExtension.swift
//  PezoParent
//
//  Created by Osmely Fernandez on 3/7/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit


extension NSObject {
    public var thisClassName: String {
        return type(of: self).thisClassName
    }

    public static var thisClassName: String {
        return String(describing: self)
    }
}


extension UIView{

    func addSubViewFromNib() -> UIView?{
        if self.thisClassName == "UIView" {return nil}
        let view = Bundle.main.loadNibNamed(self.thisClassName, owner: self, options: nil)![0] as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.clipsToBounds = true
        self.addSubview(view)
        return view
    }

    

}

