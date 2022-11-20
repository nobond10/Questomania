//
//  GameSession.swift
//  Questomania
//
//  Created by Ярослав Косарев on 20.11.2022.
//

import Foundation

typealias PassedQuestion = (question: QuestQuestion, answer: String?, selectedVariant: VariantsQuestion.Variant?)

class GameSession {
    var passedQuestions: [PassedQuestion] = []
    var availablePrompts: [TextQuestion.Prompt] = []
//    var timers: [Timer] = []

    func addQuestion(_ question: QuestQuestion, answer: String? = nil, selectedVariant: VariantsQuestion.Variant? = nil) {
        if !contains(question: question) {
            let newElement: PassedQuestion = (question: question, answer: answer, selectedVariant: selectedVariant)
            passedQuestions.append(newElement)
        }
    }

    func getAnswerForQuestion(_ question: QuestQuestion) -> String? {
        for passedQuestion in passedQuestions {
            if passedQuestion.question === question {
                return passedQuestion.answer
            }
        }
        return nil
    }
    
    func getSelectedVariantForQuestion(_ question: QuestQuestion) -> VariantsQuestion.Variant? {
        for passedQuestion in passedQuestions {
            if passedQuestion.question === question {
                return passedQuestion.selectedVariant
            }
        }
        return nil
    }

    func contains(question: QuestQuestion) -> Bool {
        return passedQuestions.map{$0.question}.contains { qq in
            qq === question
        }
    }
    
    func numberOfQuestion(_ question: QuestQuestion) -> Int {
        for (n, x) in passedQuestions.enumerated() {
            if x.question === question {
                return n + 1
            }
        }
        return passedQuestions.count + 1
    }
    
    func handlePrompt(_ prompt: TextQuestion.Prompt) {
        let interval = prompt.intervalInSeconds
        Timer.scheduledTimer(withTimeInterval: Double(interval), repeats: false) { [weak self] timer in
            self?.timerEnded(prompt: prompt, timer: timer)
        }
    }
    
    func timerEnded(prompt: TextQuestion.Prompt, timer: Timer) {
        timer.invalidate()
//        timers.removeAll { savedTimer in
//            timer === savedTimer
//        }
        let passedQuestions = passedQuestions.map {$0.question}
        for question in passedQuestions {
            if let textInputQuestion = question as? TextQuestion {
                if textInputQuestion.firstPrompt === prompt || textInputQuestion.secondPrompt === prompt {
                    return
                }
            }
        }
        availablePrompts.append(prompt)
        NotificationCenter.default.post(name: .newPrompt, object: nil)
    }
    
    func isPromptAvailable(prompt: TextQuestion.Prompt) -> Bool {
        return availablePrompts.contains { savedPrompt in
            savedPrompt === prompt
        }
    }
    
    func removeAllPromptsAndTimsers() {
//        for timer in timers {
//            timer.invalidate()
//        }
//        timers = []
        availablePrompts = []
    }
}
