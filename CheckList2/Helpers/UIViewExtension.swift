//
//  UIViewExtensio.swift
//  CheckList2
//
//  Created by Michele De Sena on 13/03/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//


import UIKit

extension UIView {
    func fadeIn() {
        self.isHidden = false
        self.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1
        }
    }

    func fadeOut() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0
        }
    }
}
