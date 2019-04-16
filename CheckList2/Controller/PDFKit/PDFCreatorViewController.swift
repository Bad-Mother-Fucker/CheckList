//
//  PDFCreatorViewController.swift
//  CheckList2
//
//  Created by Michele De Sena on 04/03/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import UIKit
import SimplePDF

class PDFCreator {

    var collection: Collezione?


    var mancanti: [String] {
        var arrayMancanti: [String] = []
       collection?.collezionabili.forEach({ (element) in
            if element.stato == CLCollectionItemState.mancante {
                arrayMancanti.append("\(element.numero ?? 0)")
            }
        })
        return arrayMancanti
    }

    var ripetute: [String] {
        var arrayRipetute: [String] = []
        collection?.collezionabili.forEach({ (element) in
            switch element.stato {
            case .ripetuto(rep: let rep):
                arrayRipetute.append("\(element.numero!) (x\(rep))")
            default:
                break
            }
        })
       return arrayRipetute

    }

    var posseduti: [String] {
        var arrayPossedute: [String] = []
        collection?.collezionabili.forEach({ (element) in
            switch element.stato {
            case .posseduto:
                arrayPossedute.append("\(element.numero!)")
            default:
                break
            }
        })
        return arrayPossedute

    }



    func createPDF(ofSize size: PaperSize, contentTypes contents: [ContentType]) -> URL? {
        let pdf = SimplePDF(pageSize: size.rawValue, pageMargin: 20)
        pdf.addVerticalSpace(30)
        pdf.addImage(UIImage(named: "Checklist") ?? UIImage())
        pdf.addVerticalSpace(20)
        pdf.addAttributedText(NSAttributedString(string: collection!.nome, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: .bold)]))
        pdf.addVerticalSpace(10)
        pdf.addText(NSLocalizedString("pdfTimestampUpdate", comment: "") + " \(Date.stringTimestamp)" )
        pdf.addVerticalSpace(50)
        var numeri: [[String]] = []
        for content in contents {
            switch content {
            case .mancanti:
                numeri.append(mancanti)
            case .ripetute:
                numeri.append(ripetute)
            case .possedute:
                numeri.append(posseduti)
                
            }


            let index = contents.index(of: content)!
            pdf.addAttributedText(NSAttributedString(string: content.rawValue, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)]))

            pdf.addLineSeparator()
            pdf.addVerticalSpace(30)


            pdf.addAttributedText(NSAttributedString(string: numeri[index].joined(separator: " - "), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))

            guard index == contents.count else {
                pdf.addVerticalSpace(70)
                continue
            }
        }

        pdf.addVerticalSpace(20)
        pdf.addText(NSLocalizedString("BottomPagePdfLine", comment: ""), font: .systemFont(ofSize: 15), textColor: .lightGray)



        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {

            let fileName = "CheckList \(collection!.nome.cleanForURL()).pdf"
            let documentsFileName = documentDirectories + "/" + fileName

            let pdfData = pdf.generatePDFdata()
            let url = URL(fileURLWithPath: documentsFileName)
            do{
                try pdfData.write(to: url, options: .atomicWrite)

            } catch {
                print(error)
            }
            return url
        }
        return nil
    }


}


enum PaperSize {
    typealias RawValue = CGSize
    case A4
    case A3

}


enum ContentType: String {
    case mancanti = "Mancanti"
    case ripetute = "Ripetute"
    case possedute = "Possedute"
}


extension PaperSize {
    var rawValue: CGSize {
        switch self {
        case .A4 :
            return CGSize(width: 595, height: 842)
        case .A3:
            return CGSize()
        }
    }

}


