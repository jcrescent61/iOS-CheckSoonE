//
//  ServerAPI.swift
//  iOS-CheckSoonE
//
//  Created by Ellen J on 2023/04/06.
//

import Foundation

protocol ServerAPI {
    var method: HTTPMethod { get }
    var path: String { get }
    var params: [String: String]? { get }
    var header: [String: String]? { get }
}
