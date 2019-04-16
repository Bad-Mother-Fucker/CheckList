//
//  DateExtension.swift
//  CheckList2
//
//  Created by Michele De Sena on 13/03/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import Foundation

extension Date {
    static func uniqueTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd:MM:yy:hh:mm:ss"
        return formatter.string(from: self.init())
    }

    static var stringTimestamp: String {
        let formatter = DateFormatter()
        let dateFormat = NSLocalizedString("localizedDateFormat", comment: "")

        guard dateFormat != "localizedDateFormat" else {
            formatter.dateFormat = "dd-MM-yyyy"
            return formatter.string(from: Date())
        }
        formatter.dateFormat = dateFormat
        return formatter.string(from: Date())
    }
}
