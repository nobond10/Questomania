//
//  PlayerInputVC.swift
//  Questomania
//
//  Created by Ярослав Косарев on 20.11.2022.
//

import UIKit

class PlayerInputVC: CommonPlayerViewController {
    
    let question: TextQuestion
    
    init(question: TextQuestion, gameSession: GameSession) {
        self.question = question
        super.init(gameSession: gameSession, nibName: "PlayerInputVC")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var textFieldAnswer: TextFieldWithLeftView!
    @IBOutlet weak var labelQuestion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitle(for: question)

        newTitleAndPrompts()
        
        if let prompt1 = question.firstPrompt {
            gameSession.handlePrompt(prompt1)
        }
        if let prompt2 = question.secondPrompt {
            gameSession.handlePrompt(prompt2)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(newTitleAndPrompts), name: .newPrompt, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let savedAnswer = gameSession.getAnswerForQuestion(question) {
            self.textFieldAnswer.isUserInteractionEnabled = false
            self.textFieldAnswer.text = savedAnswer
        } else {
            self.textFieldAnswer.isUserInteractionEnabled = true
        }
    }
    
    @objc func newTitleAndPrompts() {
        var title = question.question
        
        if let prompt1 = question.firstPrompt, gameSession.isPromptAvailable(prompt: prompt1) {
            title = title + "\n Подсказка №1: " + prompt1.text
        }
        
        if let prompt2 = question.secondPrompt, gameSession.isPromptAvailable(prompt: prompt2) {
            title = title + "\n Подсказка №2: " + prompt2.text
        }
        
        labelQuestion.text = title
    }

    @IBAction func buttonNextClicked(_ sender: Any) {
        let answerIsCorrect = textFieldAnswer?.text == question.answer
        if answerIsCorrect {
            gameSession.addQuestion(question, answer: question.answer)
            showNextQuestionInPlayerFor(question, gameSession: gameSession)
            NotificationCenter.default.removeObserver(self)
        } else {
            let alert = UIAlertController.createOkCancelAlert(title: "Ваш ответ неверен")
            present(alert, animated: true)
        }
    }
}
