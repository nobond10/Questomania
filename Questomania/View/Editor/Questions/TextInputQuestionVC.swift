//
//  TextInputQuestionVC.swift
//  Questomania
//
//  Created by Ярослав Косарев on 17.11.2022.
//

import UIKit

class TextInputQuestionVC: CommonEditorViewController {
    
    let question: TextQuestion
    
    init(question: TextQuestion, parentQuestion: QuestQuestion? = nil, variantQuestionOption: VariantsQuestion.Variant? = nil, quest: Quest? = nil) {
        self.question = question
        super.init(parentQuestion: parentQuestion, variantQuestionOption: variantQuestionOption, quest: quest, childNibName: "TextInputQuestionVC")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var textFieldAnswer: TextFieldWithLeftView!
    @IBOutlet weak var textViewQuestion: UITextView!
    
    private var firstPrompt = TextQuestion.Prompt()
    @IBOutlet weak var buttonFirstPrompt: UIButton!
    @IBOutlet weak var buttonSecondPrompt: UIButton!
    private var secondPrompt = TextQuestion.Prompt()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textViewQuestion.text = question.question
        textFieldAnswer.text = question.answer

        textViewQuestion.makeBorder()
        
        firstPrompt.text = question.firstPrompt?.text ?? ""
        firstPrompt.intervalInSeconds = question.firstPrompt?.intervalInSeconds ?? 0
        
        secondPrompt.text = question.secondPrompt?.text ?? ""
        secondPrompt.intervalInSeconds = question.secondPrompt?.intervalInSeconds ?? 0
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(buttonSaveClicked))
        
        updatePromptButtons()
    }
    
    @IBAction func buttonPrompt1Clicked(_ sender: Any) {
        showPromptSettings(prompt: firstPrompt)
    }
    
    @IBAction func buttonPrompt2Clicked(_ sender: Any) {
        if firstPrompt.isSet {
            showPromptSettings(prompt: secondPrompt)
        } else {
            let alert = UIAlertController.createOkCancelAlert(title: "Сначала настройте первую подсказку")
            present(alert, animated: true)
        }
    }
    
    func updatePromptButtons() {
        if firstPrompt.isSet {
            buttonFirstPrompt.setTitle("Интервал \(firstPrompt.intervalInSeconds), текст: \(firstPrompt.text)", for: .normal)
            buttonFirstPrompt.setTitle("Интервал \(firstPrompt.intervalInSeconds), текст: \(firstPrompt.text)", for: .selected)
//            buttonFirstPrompt.titleLabel?.text = "Интервал \(firstPrompt.intervalInSeconds), текст: \(firstPrompt.text)"
        } else {
//            var config = UIButton.Configuration.plain()
//            config.subtitle = "Не настроена"
//            buttonFirstPrompt.configuration = config
            buttonFirstPrompt.setTitle("Подсказка №1 не настроена", for: .normal)
            buttonFirstPrompt.setTitle("Подсказка №1 не настроена", for: .selected)
//            buttonFirstPrompt.titleLabel?.text = "Подсказка №1 не настроена"
        }
        if secondPrompt.isSet {
//            var config = UIButton.Configuration.plain()
//            config.subtitle = "Интервал \(secondPrompt.intervalInSeconds), текст: \(secondPrompt.text)"
//            buttonSecondPrompt.configuration = config
//            buttonSecondPrompt.titleLabel?.text = "Интервал \(secondPrompt.intervalInSeconds), текст: \(secondPrompt.text)"
            buttonSecondPrompt.setTitle("Интервал \(secondPrompt.intervalInSeconds), текст: \(secondPrompt.text)", for: .normal)
            buttonSecondPrompt.setTitle("Интервал \(secondPrompt.intervalInSeconds), текст: \(secondPrompt.text)", for: .selected)
        } else {
//            var config = UIButton.Configuration.plain()
//            config.subtitle = "Не настроена"
//            buttonSecondPrompt.configuration = config
//            buttonSecondPrompt.titleLabel?.text = "Подсказка №2 не настроена"
            buttonSecondPrompt.setTitle("Подсказка №2 не настроена", for: .normal)
            buttonSecondPrompt.setTitle("Подсказка №2 не настроена", for: .selected)
        }
    }
    
    func showPromptSettings(prompt: TextQuestion.Prompt) {
        let alert = UIAlertController(title: "Настойте первую подсказку", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.makeBorder()
            tf.placeholder = "Текст подсказки"
            tf.text = prompt.text
//            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        alert.addTextField { tf in
            tf.makeBorder()
            tf.placeholder = "Введите интервал в секундах"
            tf.text = "\(prompt.intervalInSeconds)"
            tf.keyboardType = .numbersAndPunctuation
//            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { _ in
            let text = alert.textFields![0].text ?? ""
            let interval = Int(alert.textFields![1].text ?? "") ?? 0
            prompt.text = text
            prompt.intervalInSeconds = interval
            self.updatePromptButtons()
        }))
        alert.addAction(UIAlertAction(title: "Удалить подсказку", style: .default, handler: { _ in
            prompt.intervalInSeconds = 0
            prompt.text = ""
            self.updatePromptButtons()
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func buttonSaveClicked() {
        question.question = textViewQuestion.text
        question.answer = textFieldAnswer.text ?? ""
        
        if firstPrompt.isSet {
            question.firstPrompt = firstPrompt
        } else {
            question.firstPrompt = nil
        }
        
        if secondPrompt.isSet {
            question.secondPrompt = secondPrompt
        } else {
            question.secondPrompt = nil
        }
        
        if let parentQuestion = parentQuestion {
            parentQuestion.nextQuestion = question
            question.previousQuestion = parentQuestion
        }
        if let variantQuestionOption = variantQuestionOption {
            variantQuestionOption.nextQuestion = question
        }
        if let quest = quest {
            quest.firstQuestion = question
        }
        self.navigationController?.popViewController(animated: true)
    }
}
