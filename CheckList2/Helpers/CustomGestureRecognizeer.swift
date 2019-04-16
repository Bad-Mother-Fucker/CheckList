//
//  CustomGestureRecognizeer.swift
//  CheckList2
//
//  Created by Michele De Sena on 13/03/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import Foundation
import UIKit


class UIShortDoubleTapGestureRecognizer: UITapGestureRecognizer {
    let maxDelay = 0.245
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        DispatchQueue.main.asyncAfter(deadline:.now() + maxDelay) {
            if self.state != .recognized {
                self.state = .failed
            }
        }

    }
}

class UIShortPressGestureRecognizer: UILongPressGestureRecognizer {
    let maxDuration = 0.1

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        super.pressesBegan(presses, with: event)
        DispatchQueue.main.asyncAfter(deadline:.now() + maxDuration) {
            self.state = .ended
        }
    }
}
