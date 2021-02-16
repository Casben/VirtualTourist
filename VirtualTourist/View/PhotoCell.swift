//
//  PhotoCell.swift
//  VirtualTourist
//
//  Created by Herbert Dodge on 7/25/20.
//  Copyright © 2020 Herbert Dodge. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    static let reuseIdentifier = "PhotoCell"
    
    let imageView = UIImageView()
    let activityIndicator = UIActivityIndicatorView()
    var imageUrl: String = ""
    
    //MARK: - Intializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        backgroundColor = .systemGray5
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - Helpers
    func configure() {
        addSubviews(imageView, activityIndicator)
        
        let views = [imageView, activityIndicator]
        
        for view in views {
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: self.topAnchor),
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
    }
}
