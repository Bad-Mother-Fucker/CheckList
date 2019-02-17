//
//  Collection.swift
//  CheckList
//
//  Created by Michele De Sena on 04/02/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import Foundation
import UIKit

class Collezione : NSObject {
    var uuid: String = ""
    var nome: String
    var editore: String
    private var posseduti: Int = 0
    var numeroPosseduti: Int {
        get {
            return posseduti
        }
        set {
            posseduti = newValue
        }

    }
    var collezionabili: [CollectionElement] = []
    var foto: UIImage?

    init(nome: String, editore: String) {

        self.nome = nome
        self.editore = editore
        super.init()
        self.uuid = nome + editore + "\(hashValue)"
    }
    
}


class CollezioneNumerata: Collezione {


    var isChecklistMode: Bool = false

    var numeroElementi: Int

    var numeroMancanti: Int {
        return numeroElementi - numeroPosseduti
    }

    override var numeroPosseduti: Int {
        get {
            return collezionabili.filter({ (c) -> Bool in

                switch c.stato {
                case .posseduto, .ripetuto(rep: _):
                    return true
                default:
                    return false
                }
            }).count
        }
        set {
            
        }

    }

    var completamento: CGFloat {
        if numeroElementi == 0 { return 0 }
        return CGFloat(numeroPosseduti)/CGFloat(numeroElementi)
    }

    init(nome: String, editore: String, numeroElementi: Int,uuid: String = Date.stringTimeStamp()) {
        self.numeroElementi = numeroElementi
        super.init(nome: nome, editore: editore)
        for x in 1...numeroElementi {
            let c = CollectionElement()
            c.numero = x
            collezionabili.append(c)
        }
    }

    init() {
        self.numeroElementi = 0
        super.init(nome: "", editore: "")
        self.uuid = nome + editore + "\(hashValue)"
        print("creo con uuid \(uuid)")
    }

}


extension Array where Element: CollectionElement {
    func copy() -> [Element] {
        let copy = Array(self)
        return copy
    }
}
