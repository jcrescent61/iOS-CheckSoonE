//
//  CheckSoonEError.swift
//  iOS-CheckSoonE
//
//  Created by Ellen J on 2023/04/06.
//

import Foundation

enum CheckSoonEError: LocalizedError {
    case custom(String)
    
    var localizedDescription: String {
        switch self {
        case .custom(let message):
            return message
        }
    }
}
