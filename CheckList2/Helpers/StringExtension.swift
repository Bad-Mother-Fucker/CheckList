//
//  StringExtension.swift
//  CheckList2
//
//  Created by Michele De Sena on 13/03/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import Foundation

extension String {
    func cleanForURL() -> String {
        if self.contains("/") {
            let string = self.replacingOccurrences(of: "/", with: "-")
            return string
        }
        return self
    }
}
