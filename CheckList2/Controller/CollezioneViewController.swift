//
//  CollezioneViewController.swift
//  CheckList
//
//  Created by Michele De Sena on 04/02/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import UIKit

class CollezioneViewController: UIViewController {

    var collezione: Collezione? {
        guard collectionIndex != nil else { return nil }
        return User.shared.collezioni[collectionIndex!]
    }
    var collectionIndex: Int?



    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

}
