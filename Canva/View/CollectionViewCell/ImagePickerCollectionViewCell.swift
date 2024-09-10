//
//  ImagePickerCollectionViewCell.swift
//  Canva
//
//  Created by Aleyna Işıkdağlılar on 10.09.2024.
//

import UIKit
import Kingfisher

final class ImagePickerCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "CategoryCollectionViewCell"
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private func addConstraints() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with photo: Photo) {
        if let url = URL(string: photo.src.medium) {
            imageView.kf.setImage(with: url)
        }
    }
}
