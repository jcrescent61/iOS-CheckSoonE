//
//  NaverBooksAPI.swift
//  iOS-CheckSoonE
//
//  Created by Ellen J on 2023/04/06.
//

import Foundation

enum NaverBooksAPI: Decodable {
    case detailBookInfo(
        isbn: String
    )
}

extension NaverBooksAPI: ServerAPI {
    var method: HTTPMethod {
        switch self {
        case .detailBookInfo:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .detailBookInfo:
            return "https://openapi.naver.com/v1/search/book_adv.json"
        }
    }
    
    var params: [String : String]? {
        switch self {
        case .detailBookInfo(let isbn):
            return [
                "d_isbn": isbn
            ]
        }
    }
    
    var header: [String : String]? {
        switch self {
        case .detailBookInfo:
            return [
                "X-Naver-Client-Id": "_JssNOj_eGd_F_o_OtIl",
                "X-Naver-Client-Secret": "a3laifX9kQ"
            ]
        }
    }
}
