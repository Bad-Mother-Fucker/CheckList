//
//  IAPurchaseDelegate.swift
//  CheckList2
//
//  Created by Michele De Sena on 13/03/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import Foundation
import StoreKit


protocol IAPurchaseDelegate {
    func didBuy(_ product: SKProduct)
    func didCancelPayment(for reason: Error)
}
