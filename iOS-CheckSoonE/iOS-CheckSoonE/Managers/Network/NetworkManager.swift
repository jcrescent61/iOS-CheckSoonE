//
//  NetworkManager.swift
//  iOS-CheckSoonE
//
//  Created by Ellen J on 2023/04/06.
//

import Foundation
import Combine

protocol Requester {
    func request(
        urlRequest: URLRequest,
        completion: @escaping (Result<URLSession.Response?, Swift.Error>) -> Void
    )
}

extension URLSession: Requester {
    struct Response {
        let data: Data?
        let status: Int
    }
    
    func request(
        urlRequest: URLRequest,
        completion: @escaping (Result<Response?, Error>) -> Void
    ) {
        dataTask(with: urlRequest) { data, response, error in
            if let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) {
                completion(.success(.init(data: data, status: response.statusCode)))
            } else if let error = error {
                completion(.failure(error))
            } else {
                guard let response = response as? HTTPURLResponse else { return }
                completion(.failure(NSError(domain: "UnKnown Network Error \(response.statusCode)", code: -999)))
                print(response.statusCode)
            }
        }.resume()
    }
}

protocol Networkerable {
    func request<T: Decodable>(
        _ api: ServerAPI
    ) -> AnyPublisher<T, Error>
}

final class NetworkManager {
    
    private let requester: Requester
    
    init(
        requester: Requester = URLSession(configuration: .default)
    ) {
        self.requester = requester
    }
}

extension NetworkManager: Networkerable {
    func request<T: Decodable>(_ api: ServerAPI) -> AnyPublisher<T, Error> {
        
        switch api.method {
            // MARK: - Get
        case .get:
            var urlComponents = URLComponents(string: api.path)
            
            var parameters: [URLQueryItem] = []
            api.params?.forEach({ key, value in
                parameters.append(URLQueryItem(name: key, value: "\(value)"))
            })
            
            var body = [
                "X-Naver-Client-Id": "_JssNOj_eGd_F_o_OtIl",
                "X-Naver-Client-Secret": "a3laifX9kQ",
            ]
            

            
            urlComponents?.queryItems = parameters
            
            guard let url: URL = urlComponents?.url else {
                return Fail(error: NSError(domain: "", code: -44)).eraseToAnyPublisher()
            }
            
            var urlRequest = URLRequest(url: url)
            
            urlRequest.httpMethod = api.method.rawValue
            
            api.header?.forEach { key, value in
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
            
            return request(urlRequest: urlRequest)
            // MARK: - Post, Put, Delete
        case .post, .put, .delete:
            let urlComponents = URLComponents(string: api.path)
            
            guard let url: URL = urlComponents?.url else {
                return Fail(error: NSError(domain: "", code: -44)).eraseToAnyPublisher()
            }
            
            var urlRequest = URLRequest(url: url)
            
            urlRequest.httpMethod = api.method.rawValue
            
            let jsonData = try? JSONSerialization.data(withJSONObject: api.params ?? [:])
            urlRequest.httpBody = jsonData
            
            api.header?.forEach { key, value in
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
            
            return request(urlRequest: urlRequest)
        }
    }
}

private extension NetworkManager {
    func request<T: Decodable>(
        urlRequest: URLRequest
    ) -> AnyPublisher<T, Error> {
        return Future<T, Error> { [weak self] promise in
            
            guard let self = self else {
                promise(.failure(NSError(domain: "Unknown Networker Error",
                                         code: -999, userInfo: nil)))
                return
            }
            
            self.requester.request(urlRequest: urlRequest) { result in
                switch result {
                case .success(let response):
                    
                    if let data = response?.data {
                        guard let json = try? JSONDecoder().decode(T.self, from: data) else {
                            promise(.failure(NSError(domain: "JSONParsing Networker Error",
                                                     code: -998, userInfo: nil)))
                            return
                        }
                        promise(.success(json))
                    } else {
                        promise(.failure(NSError(domain: "DataParsing Networker Error",
                                                 code: -997, userInfo: nil)))
                    }
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}

