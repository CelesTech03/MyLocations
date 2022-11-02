//
//  String+AddText.swift
//  MyLocations
//
//  Created by Celeste Urena on 11/2/22.
//

import Foundation

extension String {
    // Ask the string to add some text to itself. If string is not empty, add the specified separator first before adding the new text
    mutating func add(text: String?, separatedBy separator: String = "") {
        
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}
