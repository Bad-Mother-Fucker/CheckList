//
//  Collezionabile.swift
//  CheckList
//
//  Created by Michele De Sena on 04/02/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CollectionElement: NSObject, NSCopying, NSCoding, NSSecureCoding {
    static var supportsSecureCoding: Bool = true 

    func encode(with aCoder: NSCoder) {

        aCoder.encode(self.nome, forKey: "nome")
        aCoder.encode(self.rarità, forKey: "rarita")
        aCoder.encode(self.numero, forKey: "numero")
        aCoder.encode(self.informazioni, forKey: "informazioni")
        aCoder.encode(foto?.pngData(), forKey: "foto")

        aCoder.encode(self.stato.rawValue, forKey: "stato")
    }


    required init?(coder aDecoder: NSCoder) {
        nome = aDecoder.decodeObject(forKey: "nome") as? String
        rarità = aDecoder.decodeObject(forKey: "rarita") as? String
        numero = aDecoder.decodeObject(forKey: "numero") as! Int
        informazioni = aDecoder.decodeObject(forKey: "informazioni") as? String
        let rawState = aDecoder.decodeInteger(forKey: "stato")
        stato = MDCollectionItemState(rawValue: rawState) ?? .mancante
       

        if let fotoData = aDecoder.decodeObject(forKey: "foto") as? Data {
            foto = UIImage(data: fotoData)
        }
        super.init()
    }



    func copy(with zone: NSZone? = nil) -> Any {
        let copy = CollectionElement(nome: nome, rarità: rarità, informazioni: informazioni, numero: numero, foto: foto)
        return copy 
    }

    var nome: String?
    var rarità: String?
    var numero: Int?
    var informazioni: String?
    var foto: UIImage?
    var stato: MDCollectionItemState = .mancante

    

    init(nome: String?, rarità: String?, informazioni: String?, numero: Int?, foto: UIImage?) {
        self.nome = nome
        self.rarità = rarità
        self.informazioni = informazioni
        self.numero = numero
        self.foto = foto

    }

    init(from obj: CollezionabileMO) {
        let element = CollectionElement()
        element.foto = UIImage(data: obj.foto!)
        element.informazioni = obj.informazioni
        element.nome = obj.nome
        element.numero = Int(obj.numero)
        element.rarità = obj.rarita
        element.stato = MDCollectionItemState(rawValue: Int(obj.stato)) ?? .mancante
    }

    override init() {
        super.init()
        nome = nil
        rarità = nil
        informazioni = nil
        numero = nil
        foto = nil
    }


}


enum MDCollectionItemState: Codable {
    case mancante
    case ripetuto(rep: Int)
    case posseduto

}

extension MDCollectionItemState: RawRepresentable {

    typealias RawValue = Int

    public init?(rawValue: RawValue) {
        switch rawValue {
        case 0:
            self = .mancante
        case 1:
            self = .posseduto
        default:
            self = .ripetuto(rep: rawValue)
        }
    }

    public var rawValue: Int {
        switch self {
        case .mancante:
            return 0
        case .posseduto:
            return 1
        case .ripetuto(rep: let count):
            return count
        }
    }


}


extension NSCoder {
    class func empty() -> NSCoder {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        let data = archiver.encodedData
        return try! NSKeyedUnarchiver(forReadingFrom: data as Data)
    }


}
