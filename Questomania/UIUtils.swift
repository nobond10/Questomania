//
//  UIUtils.swift
//  Questomania
//
//  Created by Ярослав Косарев on 17.11.2022.
//

import UIKit

extension UIView {
    func makeBorder() {
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true
    }
}
