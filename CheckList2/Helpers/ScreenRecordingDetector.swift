//
//  ScreenRecordingDetector.swift
//  CheckList2
//
//  Created by Michele De Sena on 16/03/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import Foundation
import UIKit


class ScreeRecordingDetector {

    weak var delegate: ScreenRecordingDetectorObserver?

    var isRecording: Bool {
        for screen in UIScreen.screens {
            if #available(iOS 11.0, *) {
                if screen.isCaptured {
                    return true
                } else {
                    return false
                }

            }
        }
        return false
    }

    var isMirroring: Bool {
        for screen in UIScreen.screens {
            if screen.isCaptured {
                return true
            } else {
                return false
            }
        }
        return false
    }




    private var lastRecordingState: Bool = false {
        didSet {
            if lastRecordingState {
                print("start recording")
                delegate?.userDidStartRecordingScreen?()
            } else {
                print("stop recording")
                delegate?.userDidFinishRecordingScreen?()
            }
        }
    }

    private var lastMirroringState: Bool = false {
        didSet {
            if lastMirroringState {
                delegate?.userDidStartRecordingScreen?()
            } else {
                delegate?.userDidFinishRecordingScreen?()
            }
        }
    }

    func startDetector() {
        checkRecordingTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            self.checkCurrentRecordingStatus()
        }
    }

    func stopDetector() {
        checkRecordingTimer.invalidate()
        checkRecordingTimer = nil
    }


    private var checkRecordingTimer: Timer!

    private func checkCurrentRecordingStatus() {

        if lastRecordingState != isRecording {
            lastRecordingState = isRecording
        }

        if lastMirroringState != isMirroring {
            lastMirroringState = isMirroring
        }
    }

}




@objc protocol ScreenRecordingDetectorObserver {

    @available (iOS 11.0, *)
    @objc optional func userDidStartRecordingScreen()

    @available (iOS 11.0, *)
    @objc optional func userDidFinishRecordingScreen()

    @objc optional func userDidStartMirroringScreen()
    @objc optional func userDidFInishMirroringScreen()
}
