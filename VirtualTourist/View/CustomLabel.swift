//
//  CustomLabel.swift
//  VirtualTourist
//
//  Created by Herbert Dodge on 7/25/20.
//  Copyright © 2020 Herbert Dodge. All rights reserved.
//

import UIKit

class CustomLabel: UILabel {
    
    
    //MARK: - Initalizers
    init(title: String, fontSize: CGFloat) {
        super.init(frame: .zero)
        configure(title: title, fontSize: fontSize)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    //MARK: - Configuration
    func configure(title: String, fontSize: CGFloat) {
        text = title
        textColor = .white
        textAlignment = .center
        font = .boldSystemFont(ofSize: fontSize)
    }
    
}
