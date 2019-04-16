//
//  User.swift
//  CheckList
//
//  Created by Michele De Sena on 04/02/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import Foundation


class User: NSObject {
    static let shared = User()
    private override init() {}
    
    var nome: String?
    var cognome: String?
    var collezioni: [Collezione] = []
    var purchasedProducts: [SKProductIdentifier] {
        return UserDefaults.standard.array(forKey: "purchasedProducts") as? [SKProductIdentifier] ?? []
    }

    func purchaseProduct(_ identifier: SKProductIdentifier) {
        var products = purchasedProducts
        products.append(identifier)
        UserDefaults.standard.set(products, forKey: "purchasedProducts")
        UserDefaults.standard.synchronize()
    }
}
