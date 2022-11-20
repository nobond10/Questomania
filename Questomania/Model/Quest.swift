//
//  Quest.swift
//  Questomania
//
//  Created by Ярослав Косарев on 18.11.2022.
//

import Foundation

class Quest: Codable {
    var name: String = ""
    var diskName = UUID().uuidString
    
    var firstQuestion: QuestQuestion?
    
    init(name: String) {
        self.name = name
    }
    
    private enum CodingKeys: CodingKey {
        case name, diskName, firstQuestion
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.diskName, forKey: .diskName)
        try container.encode(self.firstQuestion, forKey: .firstQuestion)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.diskName = try container.decodeIfPresent(String.self, forKey: .diskName) ?? ""
        self.firstQuestion = try container.decodeIfPresent(QuestQuestion.self, forKey: .firstQuestion)
        if let fq = self.firstQuestion {
            switch fq.questionType {
            case .geo:
                self.firstQuestion = try container.decodeIfPresent(GeoQuestion.self, forKey: .firstQuestion)
            case .variants:
                self.firstQuestion = try container.decodeIfPresent(VariantsQuestion.self, forKey: .firstQuestion)
            case .input:
                self.firstQuestion = try container.decodeIfPresent(TextQuestion.self, forKey: .firstQuestion)
            case .textImage:
                self.firstQuestion = try container.decodeIfPresent(TextImageQuestion.self, forKey: .firstQuestion)
            case .unknown:
                break
            }
        }
    }
}

extension Quest {
    func questionsArray() -> [QuestQuestion] {
        if let firstQuestion = firstQuestion {
            return [firstQuestion] + firstQuestion.childs()
        } else {
            return []
        }
    }
}
