//
//  RoundedImageView.swift
//  LivePerks
//
//  Created by Osmely Fernandez on 11/11/16.
//  Copyright © 2016 InfinixSoft. All rights reserved.
//

import Foundation
import UIKit
import YYWebImage

class RoundedImageView: UIImageView {

    @IBInspectable var borderRadius: CGFloat = 2.0 {
        didSet{
            self.setNeedsDisplay()
        }
    }
    var borderColor = UIColor.white.cgColor
    public var placeholderImage : UIImage?

    weak var borderLayer: CAShapeLayer?

    override func layoutSubviews() {
        super.layoutSubviews()

        // create path

        let width = min(bounds.width, bounds.height)
        let path = UIBezierPath(arcCenter: CGPoint(x:bounds.midX, y:bounds.midY), radius: width / 2, startAngle: CGFloat(0.0), endAngle: CGFloat(Double.pi * 2.0), clockwise: true)

        // update mask and save for future reference

        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask

        // create border layer

        let frameLayer = CAShapeLayer()
        frameLayer.path = path.cgPath
        frameLayer.lineWidth = borderRadius
        frameLayer.strokeColor = borderColor
        frameLayer.fillColor = nil

        // if we had previous border remove it, add new one, and save reference to new one

        self.borderLayer?.removeFromSuperlayer()
        layer.addSublayer(frameLayer)
        self.borderLayer = frameLayer
    }



    public var url : URL? {
        didSet {

            self.image = placeholderImage
            self.yy_setImage(with: url, options: .progressiveBlur)

//            self.image = placeholderImage
//            if let urlString = url?.absoluteString {
//                ImageLoader.sharedLoader.imageForUrl(urlString: urlString) { [weak self] image, url in
//                    if let strongSelf = self {
//                        DispatchQueue.main.async(execute: { () -> Void in
//                            if strongSelf.url?.absoluteString == url {
//                                strongSelf.image = image ?? strongSelf.placeholderImage
//                            }
//                        })
//                    }
//                }
//            }
        }
    }

    public func setURL(url: URL?, placeholderImage: UIImage?) {
        self.placeholderImage = placeholderImage
        self.url = url
    }

//    open func yy_setImage(with imageURL: URL?, placeholder: UIImage?, options: YYWebImageOptions = [], completion: YYWebImage.YYWebImageCompletionBlock? = nil)

    public func setURL(url: URL?, placeholderImage: UIImage?, compl:@escaping ((Bool, UIImage?) -> Void)) {
        self.placeholderImage = placeholderImage
        self.yy_setImage(with: url, placeholder:placeholderImage, options: .progressiveBlur, completion: { (image, url, type, stage, error) in
            compl((error == nil), image)
        })
    }

}
