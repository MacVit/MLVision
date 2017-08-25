//
//  RoundedShadowImageView.swift
//  MLVision
//
//  Created by Vitaliy Maksymlyuk on 8/25/17.
//  Copyright © 2017 Vitaliy Maksymlyuk. All rights reserved.
//

import UIKit

class RoundedShadowImageView: UIImageView {

    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.8
        self.layer.cornerRadius = 15
    }
}
