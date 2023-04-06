//
//  HTTPMethod.swift
//  iOS-CheckSoonE
//
//  Created by Ellen J on 2023/04/06.
//

import Foundation

enum HTTPMethod: String, CustomStringConvertible {
    case get
    case post
    case put
    case delete
    
    var description: String {
        rawValue
    }
}
