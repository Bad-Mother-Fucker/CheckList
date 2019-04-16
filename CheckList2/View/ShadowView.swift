//
//  shadowView.swift
//  AIR
//
//  Created by alfonso on 30/08/18.
//  Copyright © 2018 alfonso. All rights reserved.
//

import UIKit

class ShadowView: UIView {

    override var bounds:CGRect{
        didSet{
            setupShadow()
        }
    }
    
    private func setupShadow() {
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 18
        self.layer.shadowOpacity = 0.1
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
}
