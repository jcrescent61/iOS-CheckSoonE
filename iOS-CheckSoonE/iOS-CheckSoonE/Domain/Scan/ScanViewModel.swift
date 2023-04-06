//
//  ScanViewModel.swift
//  iOS-CheckSoonE
//
//  Created by Ellen J on 2023/04/02.
//

import Foundation
import Combine

protocol ScanViewModelInputInterface: AnyObject {
    
    func onViewDidLoad()
    func onViewDidAppear()
    func onViewDidDisappear()
    func sendPayloadInfo(_ payload: String?)
}

protocol ScanViewModelOutputInteface: AnyObject {
    
    var detailViewPublisher: AnyPublisher<NaverBooksDetailInfo, Never> { get }
    var errorAlertPublisher: AnyPublisher<CheckSoonEError, Never> { get }
}

protocol ScanViewModelInterface: AnyObject {
    
    var input: ScanViewModelInputInterface { get }
    var output: ScanViewModelOutputInteface { get }
}

final class ScanViewModel: ScanViewModelInterface {
    
    // MARK: ScanViewModelInterface
    var input: ScanViewModelInputInterface { self }
    var output: ScanViewModelOutputInteface { self }
    
    // MARK: ScanViewModelOutputInterface
    var detailViewSubject = PassthroughSubject<NaverBooksDetailInfo, Never>()
    var errorAlertSubject = PassthroughSubject<CheckSoonEError, Never>()
    
    private let networkManager: Networkerable?
    private var cancelable = Set<AnyCancellable>()
    
    init(networkManager: Networkerable) {
        self.networkManager = networkManager
    }
}

extension ScanViewModel: ScanViewModelInputInterface {
    
    func onViewDidLoad() {
        
    }
    
    func onViewDidAppear() {
        
    }
    
    func onViewDidDisappear() {
        
    }
    
    func sendPayloadInfo(_ payload: String?) {
        guard let networkManager = networkManager else { return }
        guard let payload = payload else { return }

        networkManager.request(
            NaverBooksAPI.detailBookInfo(isbn: payload)
        )
        .sink { completion in
            switch completion {
            case .finished:
                print("Request Completed")
            case .failure(let error):
                print(error)
            }
        } receiveValue: { [weak self] (model: NaverBooksDetailInfo) in
            if model.items.isEmpty {
                self?.errorAlertSubject.send(CheckSoonEError.custom("유효하지 않은 바코드입니다."))
            } else {
                self?.detailViewSubject.send(model)
            }
        }
        .store(in: &cancelable)
    }
}

extension ScanViewModel: ScanViewModelOutputInteface {
    
    var detailViewPublisher: AnyPublisher<NaverBooksDetailInfo, Never> {
        return detailViewSubject.eraseToAnyPublisher()
    }
    
    var errorAlertPublisher: AnyPublisher<CheckSoonEError, Never> {
        return errorAlertSubject.eraseToAnyPublisher()
    }
}
