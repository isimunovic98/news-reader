//
//  NewsListTableViewCell.swift
//  NewsReader
//
//  Created by Ivan Simunovic on 26.05.2021..
//

import UIKit

class NewsListTableViewCell: UITableViewCell {
    
    //MAKR: Properties
    private let articleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let articleTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 2
        return label
    }()
    
    private let articleDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray3
        label.font = label.font.withSize(11)
        label.numberOfLines = 1
        return label
    }()
    
    private let contenContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.alignment = .center
        return stackView
    }()
    
    private let textContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    //MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UI
extension NewsListTableViewCell {
    func setupView() {
        addViews()
        setupLayout()
    }
    
    func addViews() {
        textContainer.addArrangedSubviews([articleTitleLabel, articleDescriptionLabel])
        contenContainer.addArrangedSubviews([articleImage, textContainer])
        contentView.addSubview(contenContainer)
    }
    
    func setupLayout() {
        articleImage.snp.makeConstraints { (make) in
            make.size.equalTo(100)
        }
        
        contenContainer.snp.makeConstraints { (make) in
            make.height.lessThanOrEqualTo(150)
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        }
    }
}

//MARK: Methods
extension NewsListTableViewCell {
    func configure(with data: ArticleViewModel) {
        articleImage.setImageFromUrl(data.urlToImage)
        articleTitleLabel.text = data.title
        articleDescriptionLabel.text = data.description
    }
}
