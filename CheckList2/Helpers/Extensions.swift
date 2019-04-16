//
//  Extensions.swift
//  CheckList2
//
//  Created by Michele De Sena on 18/03/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import Foundation
import UIKit


extension Array where Element: NSLayoutConstraint {
    func reference(forID string: String ) -> Element? {
        return self.filter({ $0.identifier == string }).first
    }
}



extension UIColor {
    static var pastelGreen: UIColor {
        return UIColor(red: 130/255, green: 236/255, blue: 136/255, alpha: 1)
    }
    static var pastelRed: UIColor {
        return UIColor(red: 235/255, green: 91/255, blue: 78/255, alpha: 1)
    }

    
    static var mainAppColor: UIColor {
        return UIColor(red: 28/255, green: 78/255, blue: 123/255, alpha: 1)
    }

    static var secondaryAppColor: UIColor {
        return UIColor(red: 245/255, green: 166/255, blue: 35/255, alpha: 1)
    }
}


//
//  Extensions.swift
//  DownvoteN00bs
//
//  Created by Stephen Bodnar on 05/04/2017.
//  Copyright © 2017 Stephen Bodnar. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func circularImage(_ radius: CGFloat) -> UIImage {
        var imageView = UIImageView()
        if self.size.width > self.size.height {
            imageView.frame =  CGRect(x: 0, y: 0, width: self.size.width, height: self.size.width)
            imageView.image = self
            imageView.contentMode = .scaleAspectFit

        } else {
            imageView = UIImageView(image: self)
        }
        var layer: CALayer = CALayer()

        layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = radius
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return roundedImage!
    }


    // images coming from a user's phone may be roated incorrectly. This function rotates them to portrait orientation
    func unrotatedImage() -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
