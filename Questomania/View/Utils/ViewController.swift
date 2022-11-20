//
//  ViewController.swift
//  Questomania
//
//  Created by Ярослав Косарев on 19.11.2022.
//

import UIKit

extension UIViewController {
    func showNextQuestionSelectingType(for question: QuestQuestion?, quest: Quest? = nil, variantQuestionOption: VariantsQuestion.Variant? = nil) {
        let alert = UIAlertController(title: "Выберите тип следующего вопроса", message: "Какой вопрос вы хотите создать?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Набор текстов и картинок", style: .default, handler: { _ in
            let vc = TextImageQuestionVC(question: TextImageQuestion(), parentQuestion: question, variantQuestionOption: variantQuestionOption, quest: quest)
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "С вводом ответа", style: .default, handler: { _ in
            let vc = TextInputQuestionVC(question: TextQuestion(), parentQuestion: question, variantQuestionOption: variantQuestionOption, quest: quest)
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "С вариантами ответов", style: .default, handler: { _ in
            let vc = VariantsVC(question: VariantsQuestion(), parentQuestion: question, variantQuestionOption: variantQuestionOption, quest: quest)
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Гео-вопрос", style: .default, handler: { _ in
            let vc = GeoQuestionVC(question: GeoQuestion(), parentQuestion: question, variantQuestionOption: variantQuestionOption, quest: quest)
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        present(alert, animated: true)
    }

    func showNextQuestionInPlayerFor(_ question: QuestQuestion, gameSession: GameSession) {
        if let nextQuestion = question.nextQuestion {
            showQuestionInPlayerFor(nextQuestion, gameSession: gameSession)
        } else {
            let alert = UIAlertController.createOkCancelAlert(title: "Вопросы зкончились!", message: "Вы или дошли до конца (поздравляем) или ваш квест прервался из-за неправильного ответа", okTitle: "Вернуться к списку квестов", cancelTitle: "Остаться на этой странице", okCompletion: {
                self.navigationController?.popToRootViewController(animated: true)
            }, cancelCompletion: {})
            present(alert, animated: true)
        }
    }
    
    func showQuestionInPlayerFor(_ question: QuestQuestion, gameSession: GameSession) {
        if let questionPlain = question as? TextImageQuestion {
            let vc = PlayerTextImageVC(question: questionPlain, gameSession: gameSession)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let questionVariants = question as? VariantsQuestion {
            let vc = PlayerVariantsVC(question: questionVariants, gameSession: gameSession)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let questionText = question as? TextQuestion {
            let vc = PlayerInputVC(question: questionText, gameSession: gameSession)
            self.navigationController?.pushViewController(vc, animated: true)
        } else if let questionGeo = question as? GeoQuestion {
            let vc = GeoPlayerVC(question: questionGeo, gameSession: gameSession)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
