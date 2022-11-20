//
//  TextField.swift
//  Questomania
//
//  Created by Ярослав Косарев on 19.11.2022.
//

import UIKit

class TextFieldWithLeftView: UITextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        self.leftViewMode = .always
        
        makeBorder()
        
        self.addTarget(self, action: #selector(hideKeyboard), for: .primaryActionTriggered)
    }

    @objc func hideKeyboard() {
        self.endEditing(true)
    }
}
