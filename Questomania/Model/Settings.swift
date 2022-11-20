//
//  Settings.swift
//  Questomania
//
//  Created by Ярослав Косарев on 16.11.2022.
//

import UIKit

enum QuestStep: CaseIterable {
    case scrollableContent
    case textInput
    case withVariants
    case geo

    var title: String {
        switch self {
        case .scrollableContent:
            return "Слайды"
        case .textInput:
            return "Со вводом ответа"
        case .withVariants:
            return "С вариантами ответов"
        case .geo:
            return "Гео-вопрос"
        }
    }

    var image: UIImage {
        switch self {
        case .scrollableContent:
            return .init(systemName: "text.bubble")!
        case .textInput:
            return .init(systemName: "square.and.pencil")!
        case .withVariants:
            return .init(systemName: "checkmark.square")!
        case .geo:
            return .init(systemName: "location")!
        }
    }
}


