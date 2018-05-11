//
//  String+CSV.swift
//  Tracer
//
//  Created by Rob Phillips on 5/11/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import Foundation

extension String {
    func cleanedForCSV() -> String {
        let valueJoined = self.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines).joined(separator: "; ")
        return valueJoined.replacingOccurrences(of: ",", with: " ")
    }
}
