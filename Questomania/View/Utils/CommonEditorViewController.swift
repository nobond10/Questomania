//
//  CommonViewController.swift
//  Questomania
//
//  Created by Ярослав Косарев on 19.11.2022.
//

import UIKit

class CommonEditorViewController: UIViewController {
    let parentQuestion: QuestQuestion?
    let variantQuestionOption: VariantsQuestion.Variant?
    let quest: Quest?
    
    init(parentQuestion: QuestQuestion? = nil, variantQuestionOption: VariantsQuestion.Variant? = nil, quest: Quest? = nil, childNibName: String) {
        self.parentQuestion = parentQuestion
        self.variantQuestionOption = variantQuestionOption
        self.quest = quest
        super.init(nibName: childNibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Редактирование вопроса"
        navigationItem.backButtonTitle = "Назад"
    }
}

class CommonPlayerViewController: UIViewController {
    let gameSession: GameSession
    
    init(gameSession: GameSession, nibName: String) {
        self.gameSession = gameSession
        super.init(nibName: nibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func questionWasSeen(question: QuestQuestion) -> Bool {
        return gameSession.contains(question: question)
    }
    
    func setNavigationTitle(for question: QuestQuestion) {
        let number = gameSession.numberOfQuestion(question)
        navigationItem.title = "Вопрос #\(number)"
        navigationItem.backButtonTitle = "Назад"
    }
}
