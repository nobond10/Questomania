//
//  Alert.swift
//  Questomania
//
//  Created by Ярослав Косарев on 19.11.2022.
//

import UIKit

extension UIAlertController {
    static func createOkCancelAlert(title: String, message: String? = nil, okTitle: String = "OK", cancelTitle: String? = nil, okCompletion: @escaping () -> Void = {}, cancelCompletion: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: { _ in
            okCompletion()
        }))
        if let cancelTitle = cancelTitle {
            alert.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: { _ in
                cancelCompletion?()
            }))
        }
        return alert
    }
}
