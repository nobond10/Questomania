//
//  QuestQuestion.swift
//  Questomania
//
//  Created by Ярослав Косарев on 20.11.2022.
//

import Foundation

enum QuestionType: String, Codable {
    case textImage
    case input
    case variants
    case geo
    case unknown
}

class QuestQuestion: Codable {
    var nextQuestion: QuestQuestion?
    var previousQuestion: QuestQuestion?
    let questionType: QuestionType
    
    var representation: String {
        ""
    }
    
    func removeFromParent() {
        if let prevQuestion = previousQuestion {
            if let variantsQuestion = prevQuestion as? VariantsQuestion {
                for variant in variantsQuestion.variants {
                    if variant.nextQuestion === self {
                        variant.nextQuestion = nil
                    }
                }
            } else {
                prevQuestion.nextQuestion = nil
            }
        }
    }
    
    init(type: QuestionType) {
        self.questionType = type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.questionType = try container.decodeIfPresent(QuestionType.self, forKey: .questionType) ?? .unknown
        self.nextQuestion = try container.decodeIfPresent(QuestQuestion.self, forKey: .nextQuestion)
        if let nq = self.nextQuestion {
            switch nq.questionType {
            case .geo:
                self.nextQuestion = try container.decodeIfPresent(GeoQuestion.self, forKey: .nextQuestion)
            case .variants:
                self.nextQuestion = try container.decodeIfPresent(VariantsQuestion.self, forKey: .nextQuestion)
            case .input:
                self.nextQuestion = try container.decodeIfPresent(TextQuestion.self, forKey: .nextQuestion)
            case .textImage:
                self.nextQuestion = try container.decodeIfPresent(TextImageQuestion.self, forKey: .nextQuestion)
            case .unknown:
                break
            }
        }
        nextQuestion?.previousQuestion = self
    }
}

class TextImageQuestion: QuestQuestion {
    class Question: Codable {
        var text: String = ""
        var photos: [Data] = []
        var representation: String {
            var forJoin: [String] = []
            if photos.count > 0 {
                forJoin.append("фотографий: \(photos.count)")
            }
            if text.count > 0 {
                forJoin.append("текст: \(text)")
            }
            return forJoin.joined(separator: " ; ")
        }
    }
    var elements: [Question] = []
    
    override var representation: String {
        return "Вопрос с пролистыванием \(elements.count) текстовых и фото элементов"
    }
    
    init() {
        super.init(type: .textImage)
    }
    
    private enum CodingKeys: CodingKey {
        case elements, nextQuestion, questionType
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.elements, forKey: .elements)
        try container.encode(self.nextQuestion, forKey: .nextQuestion)
        try container.encode(self.questionType, forKey: .questionType)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.elements = try container.decode([Question].self, forKey: .elements)
    }
}

class TextQuestion: QuestQuestion {
    class Prompt: Codable {
        var intervalInSeconds: Int = 0
        var text: String = ""
        
        init() {}
        init(intervalInSeconds: Int, text: String) {
            self.intervalInSeconds = intervalInSeconds
            self.text = text
        }
        
        var isSet: Bool {
            return text.count > 0 && intervalInSeconds > 0
        }
    }
    var question: String = ""
    var answer: String = ""
    var firstPrompt: Prompt?
    var secondPrompt: Prompt?
    
    override var representation: String {
        return "Вопрос с вводом ответа: " + question
    }
    
    init() {
        super.init(type: .input)
    }
    
    private enum CodingKeys: CodingKey {
        case question, answer, firstPrompt, secondPrompt, nextQuestion, questionType
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.question, forKey: .question)
        try container.encode(self.answer, forKey: .answer)
        try container.encode(self.firstPrompt, forKey: .firstPrompt)
        try container.encode(self.secondPrompt, forKey: .secondPrompt)
        try container.encode(self.nextQuestion, forKey: .nextQuestion)
        try container.encode(self.questionType, forKey: .questionType)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.question = try container.decode(String.self, forKey: .question)
        self.answer = try container.decode(String.self, forKey: .answer)
        self.firstPrompt = try container.decode(Prompt.self, forKey: .firstPrompt)
        self.secondPrompt = try container.decode(Prompt.self, forKey: .secondPrompt)
    }
}

class VariantsQuestion: QuestQuestion {
    class Variant: Codable {
        var answer: String = ""
        var nextQuestion: QuestQuestion?
        
        init() {}
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.answer = try container.decodeIfPresent(String.self, forKey: .answer) ?? ""
            self.nextQuestion = try container.decodeIfPresent(QuestQuestion.self, forKey: .nextQuestion)
            if let nq = self.nextQuestion {
                switch nq.questionType {
                case .geo:
                    self.nextQuestion = try container.decodeIfPresent(GeoQuestion.self, forKey: .nextQuestion)
                case .variants:
                    self.nextQuestion = try container.decodeIfPresent(VariantsQuestion.self, forKey: .nextQuestion)
                case .input:
                    self.nextQuestion = try container.decodeIfPresent(TextQuestion.self, forKey: .nextQuestion)
                case .textImage:
                    self.nextQuestion = try container.decodeIfPresent(TextImageQuestion.self, forKey: .nextQuestion)
                case .unknown:
                    break
                }
            }
        }
    }
    var question: String = ""
    var variants: [Variant] = []
    
    override var representation: String {
        return "Вопрос с выбором ответа: " + question
    }
    
    init() {
        super.init(type: .variants)
    }
    
    private enum CodingKeys: CodingKey {
        case question, variants, nextQuestion, questionType
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.question, forKey: .question)
        try container.encode(self.variants, forKey: .variants)
        try container.encode(self.nextQuestion, forKey: .nextQuestion)
        try container.encode(self.questionType, forKey: .questionType)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.question = try container.decode(String.self, forKey: .question)
        self.variants = try container.decode([Variant].self, forKey: .variants)
        variants.forEach { variant in
            variant.nextQuestion?.previousQuestion = self
        }
    }
}

class GeoQuestion: QuestQuestion {
    var lat: Double = 0
    var lon: Double = 0
    
    override var representation: String {
        return "Гео-вопрос с точкой \(lat);\(lon)"
    }
    
    init() {
        super.init(type: .geo)
    }
    
    private enum CodingKeys: CodingKey {
        case lat, lon, nextQuestion, questionType
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.lat, forKey: .lat)
        try container.encode(self.lon, forKey: .lon)
        try container.encode(self.nextQuestion, forKey: .nextQuestion)
        try container.encode(self.questionType, forKey: .questionType)
        
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.lat = try container.decode(Double.self, forKey: .lat)
        self.lon = try container.decode(Double.self, forKey: .lon)
    }
}

extension QuestQuestion {
    func childs() -> [QuestQuestion] {
        if let variantsQuestion = self as? VariantsQuestion {
            var variantsChilds: [QuestQuestion] = []
            for variant in variantsQuestion.variants {
                if let variantNextQuestion = variant.nextQuestion {
                    let newChilds = [variantNextQuestion] + variantNextQuestion.childs()
                    variantsChilds.append(contentsOf: newChilds)
                }
            }
            return variantsChilds
        } else {
            if let nextQuestion = nextQuestion {
                return [nextQuestion] + nextQuestion.childs()
            } else {
                return []
            }
        }
    }
}
