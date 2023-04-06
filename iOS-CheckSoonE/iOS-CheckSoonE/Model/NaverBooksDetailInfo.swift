//
//  BookInfo.swift
//  iOS-CheckSoonE
//
//  Created by Ellen J on 2023/04/02.
//

import Foundation

struct NaverBooksDetailInfo: Decodable {
    let items: [BookInfo]
}

struct BookInfo: Decodable {
    let title: String?
    let image: String?
    let author: String?
    let description: String?
}
