//
//  DetailBookInfoViewController.swift
//  iOS-CheckSoonE
//
//  Created by Ellen J on 2023/04/02.
//

import UIKit

final class DetailBookInfoViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        setUpUI()
    }
    
    convenience init(_ model: NaverBooksDetailInfo) {
        self.init(nibName: nil, bundle: nil)
        titleLabel.text = model.items[0].title
    }
    
    private func setUp() {
        view.addSubview(titleLabel)
        view.backgroundColor = .white
    }
    
    private func setUpUI() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
